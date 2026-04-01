#!/usr/bin/env python3
# DESCRIPTION
# This script generates and executes combination runs for ANY CLI executable
# that accepts command-line switches. It creates simple run scripts that
# contain only the command to run. The main runner handles all interactive
# prompting, execution, and file organization. Run configurations can be
# saved to and loaded from JSON files for repeatable runs.
#
# This tool can be used as:
#   - A test automation assistant for CLI applications (verifying all switch combinations)
#   - A batch job generator (running the same command with many parameter combinations)
#   - A parameter exploration tool (systematically testing all variations)

# DEPENDENCIES
# - MSYS2 bash environment on Windows
# - Python 3.6+
# - The command under test must be executable or invokable via interpreter
# - Standard bash utilities (mv, cp, rm, etc.)

# USAGE
# Interactive mode (no config):
#   python CLI_batch_generator.py
#
# Load existing config:
#   python CLI_batch_generator.py --config my_run.json
#
# Load config and overwrite it after any changes:
#   python CLI_batch_generator.py --config my_run.json --save
#
# Load config and save as new file:
#   python CLI_batch_generator.py --config my_run.json --save-as new_run.json
#
# After generating run scripts:
#   cd suite_<commandname>_<timestamp>
#   ./run_suite_<commandname>.sh
#   Select batch or interactive mode
#
# NOTES
# - This tool tests named switches only. Positional swithces will not work.
# - Run scripts are generated as combinations, not permutations (order doesn't matter)
# - Each run uses only one value per switch
# - Mutually exclusive switches are always tested together to verify error handling
# - Switches marked as required will appear in every generated run combination
# - All run artifacts are created in your current working directory
# - The command under test can be any executable command:
#   - Simple command name:          "my_command"
#   - With interpreter:             "python script.py"
#   - Any CLI tool executable that accepts switches supported by
#     the syntax this script handles
#   - With path:                    "../tools/deploy.sh"
#   - WITHOUT path, and the script will try to find the path:        "randomBlob.py"
#   - With flags:                   "node --experimental-modules app.js"
#   - Paths with spaces (quoted):   'python "C:\\My Project\\script.py"'
# The command field can also include fixed switches that apply to all runs.
# For example: "python script.py --cores 4" will have --cores 4 in every generated command.
# This is useful for example for adding interpreter flags, or any switch you
# don't need to vary across combinations but do want to include.
#
# - CONFIGURATION FILES:
#   * JSON format, human-readable and editable
#   * Can be created interactively or manually
#   * When loading a config, missing fields prompt for input
#   * Use --save to overwrite existing config, --save-as to create new file
#   * Commands are stored as entered (portable format recommended)
#
# - HOW RUN EXECUTION WORKS:
#   * You run this generator from your working director (where your data files are)
#   * It creates individual run scripts for all possible configurations determined by data
#     which you give it via interactive prompts _or_ by loading a config. Run scripts are
#     created in a subdirectory (suite_*/)
#   * When you execute a run, the main runner executes each run in your original working directory
#   * The main runner uses its own location ($0) to find run scripts, so the run directory can be moved,
#     provided that the working directory remains above it (in practical terms, maybe only move the working
#     directory, not the run_ folder and its subfolders)
#   * The main runner handles file organization (pending/completed/skipped) and result logging
#   * Interactive mode prompts before each run with options: run, park (stays pending), skip (moves to skipped)
#
# - The user is responsible for:
#   * Providing meaningful test values and any usable data for CLIs or scripts which the runner calls
#   * Understanding switch precedence/override behavior
#   * Managing system state between runs (files, env vars, etc.)
#   * Interpreting results
# - For large switch sets, combinatorial explosion is possible. Use criticality
#   filtering and depth selection to manage test script numbers. Required switches set a minimum depth.
# Script version 2.32.5

# CODE
# TO DO
# possible v3 features:
# - Value type validation (file exists, numeric range)
# - Summary reports with statistics
# - Parallel run execution
# - Dependency testing (requires relationships)
# - Capture stdout/stderr diffs

import os
import sys
import itertools
import datetime
import re
import hashlib
import json
import argparse
import random
import string
from pathlib import Path
from typing import List, Dict, Tuple, Optional, Any
import shutil

class Switch:
    """Represents a command line switch with its metadata"""
    def __init__(self):
        self.name = ""              # Display name (e.g., "verbose")
        self.long_form = ""         # e.g., "--verbose"
        self.short_form = ""        # e.g., "-v" (can be empty)
        self.is_flag = False        # True if no value needed
        self.values = []            # List of values to run (ONE VALUE PER RUN)
        self.criticality = 'M'      # 'H'igh, 'M'edium, 'L'ow
        self.conflicts_with = []     # List of switch indices this conflicts with
        self.required = False       # If True, must be included in every run
        
    def to_dict(self) -> Dict:
        """Convert switch to dictionary for JSON serialization"""
        return {
            'name': self.name,
            'long_form': self.long_form,
            'short_form': self.short_form,
            'is_flag': self.is_flag,
            'values': self.values,
            'criticality': self.criticality,
            'required': self.required,
            'conflicts_with': self.conflicts_with
        }
    
    def from_dict(self, data: Dict) -> None:
        """Load switch from dictionary"""
        self.name = data.get('name', '')
        self.long_form = data.get('long_form', '')
        self.short_form = data.get('short_form', '')
        self.is_flag = data.get('is_flag', False)
        self.values = data.get('values', [])
        self.criticality = data.get('criticality', 'M')
        self.required = data.get('required', False)
        self.conflicts_with = data.get('conflicts_with', [])
        
    def __str__(self):
        val_display = "flag" if self.is_flag else f"values: {', '.join(str(v) for v in self.values)}"
        forms = []
        if self.short_form:
            forms.append(self.short_form)
        if self.long_form:
            forms.append(self.long_form)
        form_display = '/'.join(forms)
        req = " REQUIRED" if self.required else ""
        return f"{form_display} [{val_display}] crit:{self.criticality} conflicts:{self.conflicts_with}{req}"

def resolve_script_paths(command: str) -> str:
    """
    If script path is a simple name (no slashes), try to find it in PATH.
    Otherwise, leave it exactly as-is.
    """
    parts = command.strip().split()
    if not parts:
        return command
    
    interpreters = {
        'python', 'python3', 'python2', 'ruby', 'perl', 'node', 'php', 'bash', 'sh'
    }
    
    if parts[0] in interpreters and len(parts) > 1:
        script_path = parts[1]
        
        # Only try to resolve if it's a simple name (no path separators)
        if '/' not in script_path and '\\' not in script_path:
            found = shutil.which(script_path)
            if found:
                parts[1] = found.replace('\\', '/')
                print(f"  Resolved '{script_path}' → '{found}'")
                return ' '.join(parts)
            # If not found in PATH, leave as-is (maybe it'll be found at runtime)
        
        # Has slashes or wasn't found - leave as-is
        return command
    
    return command

def get_user_input(prompt: str, default: str = "", required: bool = False) -> str:
    """Get user input with optional default"""
    if default:
        prompt = f"{prompt} [{default}]: "
    else:
        prompt = f"{prompt}: "
    
    while True:
        response = input(prompt).strip()
        if not response and default:
            return default
        if not response and required:
            print("This field is required.")
            continue
        return response

def get_multiline_input(prompt: str) -> List[str]:
    """Get multiple lines of input until empty line"""
    print(prompt + " (Enter empty line to finish):")
    lines = []
    while True:
        line = input().strip()
        if not line:
            break
        lines.append(line)
    return lines

def gather_switches_interactive() -> List[Switch]:
    """Interactively gather switch information from user"""
    switches = []
    print("\n=== Switch Definition ===")
    print("Enter each switch one at a time. Press Enter at the 'First form' prompt to finish.")
    print("")
    print("For each switch, you'll enter its command-line forms:")
    print("  - Enter a SHORT form (e.g., -v) OR LONG form (e.g., --verbose) first")
    print("  - The script detects which you entered")
    print("  - Then you can optionally enter the other form")
    print("")
    print("Note: For switches that accept values, you may provide MULTIPLE values")
    print("      to run, but each generated run will use ONLY ONE of those values.")
    print("")
    
    switch_num = 1
    while True:
        print(f"\n--- Switch #{switch_num} ---")
        print("Enter a switch form exactly as you'd type it on the command line.")
        print("Examples: -i, --input, -v, --verbose, -f, --file")
        print("")
        
        # Get first form - press Enter to finish (if we have at least one switch)
        first_form = get_user_input("First form (or press Enter to finish)", default="")
        
        # Check if user wants to finish
        if not first_form:
            if switch_num > 1:
                print("Finished adding switches.")
                break
            else:
                print("At least one switch is required!")
                continue
        
        switch = Switch()
        
        # Parse what they entered
        if first_form.startswith('--'):
            # First form is long
            switch.long_form = first_form
            switch.short_form = ""
            print(f"  Detected LONG form: {first_form}")
            # Now ask for short form (optional)
            second_form = get_user_input("Short form (optional) - press Enter to skip", default="")
            if second_form:
                switch.short_form = second_form
        else:
            # First form is short (starts with - but not --)
            switch.short_form = first_form
            switch.long_form = ""
            print(f"  Detected SHORT form: {first_form}")
            # Now ask for long form (optional)
            second_form = get_user_input("Long form (optional) - press Enter to skip", default="")
            if second_form:
                switch.long_form = second_form
        
        # Generate a name from the first form for display
        switch.name = first_form.lstrip('-').split()[0]
        
        # Is it a flag?
        is_flag = get_user_input("Is this a flag (no value)? (y/n)", default="n").lower() == 'y'
        switch.is_flag = is_flag
        
        if not is_flag:
            print("\nEnter VALUES to run (one per line). Each generated run will use ONE of these values.")
            print("Example: if you enter 'test1.txt' and 'test2.txt', you'll get separate runs:")
            if switch.short_form:
                print(f"  command {switch.short_form} test1.txt")
            if switch.long_form:
                print(f"  command {switch.long_form} test1.txt")
            if switch.short_form:
                print(f"  command {switch.short_form} test2.txt")
            if switch.long_form:
                print(f"  command {switch.long_form} test2.txt")
            values = get_multiline_input("Enter run values")
            if not values:
                print("Warning: No values entered. Using empty string as run value.")
                values = [""]
            switch.values = values
        
        # Criticality
        crit = get_user_input("Criticality (H)igh / (M)edium / (L)ow", default="M").upper()
        if crit in ['H', 'M', 'L']:
            switch.criticality = crit
        
        # Required switch?
        required = get_user_input("Is this switch REQUIRED (must be in every run)? (y/n)", default="n").lower() == 'y'
        switch.required = required
        
        # Conflicts
        if switches:
            print("\nExisting switches:")
            for i, s in enumerate(switches, 1):
                forms = []
                if s.short_form:
                    forms.append(s.short_form)
                if s.long_form:
                    forms.append(s.long_form)
                print(f"  {i}. {'/'.join(forms)}")
            conflicts = get_user_input("Conflicts with (comma-separated numbers, e.g., '1,3' (ENTER to skip))", default="")
            if conflicts:
                try:
                    switch.conflicts_with = [int(x.strip()) - 1 for x in conflicts.split(',') if x.strip()]
                except ValueError:
                    print("Invalid input, no conflicts recorded")
        
        switches.append(switch)
        switch_num += 1
    
    return switches

def fix_incomplete_switch(switch: Switch, switch_index: int) -> bool:
    """Interactively fix an incomplete switch (missing values for non-flag switches)"""
    if switch.is_flag:
        # Flags don't need values, so nothing to fix
        return False
    
    if switch.values:
        # Already has values, nothing to fix
        return False
    
    print(f"\nSwitch {switch_index}: {switch.name} is not a flag but has no values.")
    print("You need to provide values to run with this switch.")
    
    forms = []
    if switch.short_form:
        forms.append(switch.short_form)
    if switch.long_form:
        forms.append(switch.long_form)
    form_display = '/'.join(forms) if forms else switch.name
    
    print(f"  Forms: {form_display}")
    print(f"  Criticality: {switch.criticality}")
    print(f"  Required: {'Yes' if switch.required else 'No'}")
    
    print("\nEnter VALUES to run (one per line). Each generated run will use ONE of these values.")
    print("Example: if you enter 'test1.txt' and 'test2.txt', you'll get separate runs:")
    if switch.short_form:
        print(f"  command {switch.short_form} test1.txt")
    if switch.long_form:
        print(f"  command {switch.long_form} test1.txt")
    if switch.short_form:
        print(f"  command {switch.short_form} test2.txt")
    if switch.long_form:
        print(f"  command {switch.long_form} test2.txt")
    
    values = get_multiline_input("Enter run values")
    if not values:
        print("Warning: No values entered. Using empty string as run value.")
        values = [""]
    
    switch.values = values
    return True

def validate_and_fix_switches(switches: List[Switch]) -> Tuple[bool, bool]:
    """
    Validate switches and fix incomplete ones interactively
    Returns: (valid, any_changes_made)
    """
    valid = True
    any_changes = False
    
    for i, s in enumerate(switches):
        # Check that flags have no values
        if s.is_flag and s.values:
            print(f"Warning: Switch {i+1} ({s.name}) is a flag but has values!")
            print(f"  Values: {s.values}")
            clear = get_user_input("Clear these values? (y/n)", default="y").lower()
            if clear == 'y':
                s.values = []
                any_changes = True
                print(f"  Cleared values for flag switch {s.name}")
            else:
                valid = False
        
        # Check that non-flags have at least one value
        elif not s.is_flag and not s.values:
            print(f"Error: Switch {i+1} ({s.name}) is not a flag but has no values!")
            print("This switch needs values to run. You have two options:")
            print("  1. Enter values now")
            print("  2. Skip this run (exit and fix the config file manually)")
            print("")
            
            proceed = get_user_input("Enter values now? (y/n)", default="y").lower()
            
            if proceed == 'y':
                forms = []
                if s.short_form:
                    forms.append(s.short_form)
                if s.long_form:
                    forms.append(s.long_form)
                form_display = '/'.join(forms) if forms else s.name
                print(f"  Forms: {form_display}")
                print(f"  Criticality: {s.criticality}")
                print(f"  Required: {'Yes' if s.required else 'No'}")
                
                print("\nEnter VALUES to run (one per line). Each generated run will use ONE of these values.")
                values = get_multiline_input("Enter run values")
                
                if values:
                    s.values = values
                    any_changes = True
                    print(f"  Added {len(values)} value(s) to switch {s.name}")
                else:
                    print(f"  No values entered. Switch {s.name} will have no values and will be skipped.")
                    valid = False
            else:
                print(f"Skipping switch {s.name}. It will be excluded from runs.")
                valid = False
    
    return valid, any_changes

def load_config(config_path: str, fix_missing: bool = True) -> Tuple[str, List[Switch], str, str, bool]:
    """Load run configuration from JSON file"""
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: Config file not found: {config_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in config file: {e}")
        sys.exit(1)
    
    # Extract command (support both 'command' and 'script_name' for backward compatibility)
    script_name = data.get('command', data.get('script_name', ''))
    if not script_name:
        print("Error: Config missing 'command' field")
        sys.exit(1)
    
    # Extract depth and crit_filter
    depth = data.get('depth', '2')
    crit_filter = data.get('crit_filter', 'M')
    
    # Extract switches
    switches_data = data.get('switches', [])
    if not switches_data:
        print("Error: Config missing 'switches' field or empty")
        sys.exit(1)
    
    switches = []
    for i, sw_data in enumerate(switches_data):
        switch = Switch()
        switch.from_dict(sw_data)
        switches.append(switch)
    
    # Validate and optionally fix switches
    valid, fixed = validate_and_fix_switches(switches)
    
    if not valid:
        print("Config validation failed. Please fix the config file.")
        if fixed:
            print("Some issues were automatically fixed.")
        else:
            print("Unable to automatically fix all issues.")
            sys.exit(1)
    
    print(f"Loaded config from {config_path}")
    print(f"  Command: {script_name}")
    print(f"  Switches: {len(switches)}")
    print(f"  Depth: {depth}")
    print(f"  Criticality filter: {crit_filter}")
    
    if fixed:
        print("\nNOTE: Some switch values were missing and have been filled in.")
        print("      The config file will be updated when you save.")
    
    return script_name, switches, depth, crit_filter, fixed

def save_config(config_path: str, script_name: str, switches: List[Switch], depth: str, crit_filter: str) -> None:
    """Save run configuration to JSON file"""
    if not config_path:
        print("Error: Cannot save config - no filename provided")
        return

    data = {
        '_instructions': f"Load with CLI_batch_generator.py, this way: CLI_batch_generator.py --config {config_path}",
        'command': script_name,
        'depth': depth,
        'crit_filter': crit_filter,
        'switches': [s.to_dict() for s in switches]
    }
    
    try:
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Config saved to {config_path}")
    except Exception as e:
        print(f"Error saving config: {e}")

def generate_combinations(switches: List[Switch], depth: str, crit_filter: str) -> List[Dict]:
    """
    Generate all combinations of switches at specified depth.
    
    If switches are marked as required, they are included in every combination.
    The minimum depth is the number of required switches.
    Each run uses EXACTLY ONE VALUE per switch.
    """
    # Filter by criticality
    crit_levels = {'H': 3, 'M': 2, 'L': 1}
    min_crit = crit_levels.get(crit_filter, 1)
    
    filtered_indices = []
    for i, s in enumerate(switches):
        if crit_levels[s.criticality] >= min_crit:
            filtered_indices.append(i)
    
    if not filtered_indices:
        print("Warning: No switches match criticality filter!")
        return []
    
    # Identify required switches within filtered set
    required_indices = [i for i in filtered_indices if switches[i].required]
    optional_indices = [i for i in filtered_indices if not switches[i].required]
    
    if required_indices:
        print(f"  Required switches: {len(required_indices)} (will be in every run)")
    
    # Generate combinations at each depth
    all_combinations = []
    
    # Determine max depth
    requested_depth = depth if depth == 'all' else int(depth)
    max_depth = len(filtered_indices) if depth == 'all' else int(depth)
    max_depth = min(max_depth, len(filtered_indices))
    
    # Minimum depth must be at least the number of required switches
    min_depth = len(required_indices)
    if min_depth > max_depth:
        print(f"Error: Required switches ({min_depth}) exceed max depth ({max_depth})!")
        print(f"  Use depth = {min_depth} or higher.")
        return []
    
    # Inform if requested depth exceeds available switches
    if depth != 'all' and requested_depth > len(filtered_indices):
        print(f"\nNOTE: Requested depth {requested_depth} exceeds available switches ({len(filtered_indices)}).")
        print(f"      Using maximum possible depth {len(filtered_indices)} instead.")
    
    print(f"\nGenerating combinations up to depth {max_depth} (minimum depth {min_depth})...")
    
    # For each combination size k (min_depth through max_depth)
    for k in range(min_depth, max_depth + 1):
        if required_indices:
            # Number of optional switches we need to pick
            optional_needed = k - len(required_indices)
            if optional_needed < 0:
                continue
            if optional_needed > len(optional_indices):
                continue
            
            # For each combination of optional switches
            for optional_combo in itertools.combinations(optional_indices, optional_needed):
                # Combine required + this optional combo
                combo_indices = tuple(sorted(required_indices + list(optional_combo)))
                
                # Process this combo
                switches_in_combo = [switches[i] for i in combo_indices]
                
                # Build value choices
                value_choices = []
                for s in switches_in_combo:
                    if s.is_flag:
                        value_choices.append([None])
                    else:
                        value_choices.append([[v] for v in s.values])
                
                for value_combo in itertools.product(*value_choices):
                    combo_dict = {}
                    for i, (switch_idx, value_choice) in enumerate(zip(combo_indices, value_combo)):
                        if value_choice is not None:
                            combo_dict[switch_idx] = value_choice[0]
                        else:
                            combo_dict[switch_idx] = None
                    all_combinations.append(combo_dict)
        else:
            # No required switches - standard generation
            for combo_indices in itertools.combinations(filtered_indices, k):
                switches_in_combo = [switches[i] for i in combo_indices]
                
                value_choices = []
                for s in switches_in_combo:
                    if s.is_flag:
                        value_choices.append([None])
                    else:
                        value_choices.append([[v] for v in s.values])
                
                for value_combo in itertools.product(*value_choices):
                    combo_dict = {}
                    for i, (switch_idx, value_choice) in enumerate(zip(combo_indices, value_combo)):
                        if value_choice is not None:
                            combo_dict[switch_idx] = value_choice[0]
                        else:
                            combo_dict[switch_idx] = None
                    all_combinations.append(combo_dict)
    
    return all_combinations

def has_conflict(switches: List[Switch], combo: Dict) -> bool:
    """Check if a combination has any conflicts"""
    selected_indices = list(combo.keys())
    for i in selected_indices:
        switch = switches[i]
        for conflict_idx in switch.conflicts_with:
            if conflict_idx in selected_indices:
                return True
    return False

def generate_run_scripts(switches: List[Switch], script_name: str, depth: str, crit_filter: str):
    """
    Generate simple run scripts (just the command) and the main runner.
    
    The run scripts contain only the command and metadata headers.
    The main runner handles all interactive prompting, execution, and file organization.
    """
    # Get current working directory (where the user invoked the script)
    cwd = Path.cwd()
    print(f"\nWorking directory: {cwd}")
    
    # Resolve script path in the command
    print(f"\nResolving script paths in command: {script_name}")
    actual_command = resolve_script_paths(script_name)
    print(f"  Using command: {actual_command}")
    
    # Extract a safe directory name from whatever command the user entered
    script_basename_raw = script_name.replace('\\', '/').split('/')[-1]
    if '.' in script_basename_raw:
        script_basename = script_basename_raw[:script_basename_raw.rfind('.')]
    else:
        script_basename = script_basename_raw
    script_basename = re.sub(r'[^\w\-]', '_', script_basename)
    if not script_basename:
        script_basename = "command"
    
    # Create timestamp for this run
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Create base directory and subdirectories with sanitized names
    base_dir = cwd / f"suite_{script_basename}_{timestamp}"
    pending_dir = base_dir / f"_pending_{script_basename}"
    completed_dir = base_dir / f"_completed_{script_basename}"
    skipped_dir = base_dir / f"_skipped_{script_basename}"
    
    pending_dir.mkdir(parents=True, exist_ok=True)
    completed_dir.mkdir(exist_ok=True)
    skipped_dir.mkdir(exist_ok=True)
    
    # Generate all combinations
    combos = generate_combinations(switches, depth, crit_filter)
    
    if not combos:
        print("No run combinations generated!")
        return None
    
    # Separate valid and invalid combinations (for conflict testing)
    valid_combos = []
    invalid_combos = []
    
    for combo in combos:
        if has_conflict(switches, combo):
            invalid_combos.append(combo)
        else:
            valid_combos.append(combo)
    
    total_unique = len(valid_combos) + len(invalid_combos)
    
    # Determine if we'll generate both long and short forms
    has_both_forms = False
    for switch in switches:
        if switch.long_form and switch.short_form:
            has_both_forms = True
            break
    
    form_types_count = 2 if has_both_forms else 1
    total_scripts = total_unique * form_types_count
    
    print(f"\nGenerating {total_unique} unique switch combinations...")
    print(f"  Valid combinations (no conflicts): {len(valid_combos)}")
    print(f"  Invalid combinations (with conflicts): {len(invalid_combos)}")
    if form_types_count == 2:
        print(f"  Long and short forms will create {total_scripts} total run scripts.")
    else:
        print(f"  Single form (no switches have both long and short forms) will create {total_scripts} total run scripts.")
    
    # Determine if we need both long and short forms
    # Only generate both if at least one switch has both forms defined
    has_both_forms = False
    for switch in switches:
        if switch.long_form and switch.short_form:
            has_both_forms = True
            break
    
    # Generate run scripts
    run_scripts = []
    script_index = 1
    
    # For each form type (long and short) only if both forms exist somewhere
    form_types_to_generate = [True, False] if has_both_forms else [True]  # True = long, False = short
    
    for use_long in form_types_to_generate:
        form_type = "long" if use_long else "short"
        
        # Process both valid and invalid combos
        for combo_list, combo_type in [(valid_combos, "valid"), (invalid_combos, "invalid")]:
            for combo in combo_list:
                # Build command using the resolved command
                cmd_parts = [actual_command]
                switch_parts_for_filename = []
                
                # Sort by switch index for consistent ordering
                for idx in sorted(combo.keys()):
                    switch = switches[idx]
                    value = combo[idx]
                    
                    # Choose which form to use
                    if not use_long and switch.short_form:
                        switch_text = switch.short_form
                    elif use_long and switch.long_form:
                        switch_text = switch.long_form
                    elif switch.short_form:
                        switch_text = switch.short_form
                    elif switch.long_form:
                        switch_text = switch.long_form
                    else:
                        continue
                    
                    if not switch.is_flag and value is not None:
                        cmd_parts.append(f"{switch_text} {value}")
                        val_short = str(value).replace('/', '_').replace(' ', '_')
                        switch_parts_for_filename.append(f"{switch.name}-{val_short}")
                    else:
                        cmd_parts.append(switch_text)
                        switch_parts_for_filename.append(switch.name)
                
                full_command = " ".join(cmd_parts)
                
                # Create filename with meaningful info
                crit_letters = ''.join(sorted(set(switches[i].criticality for i in combo.keys())))
                depth_indicator = f"d{len(combo)}"
                
                # Build the base name from the command (without path)
                cmd_basename = script_name.split('/')[-1].split('\\')[-1]
                # Remove any file extension
                if '.' in cmd_basename:
                    cmd_basename = cmd_basename[:cmd_basename.rfind('.')]
                # Remove any problematic characters
                cmd_basename = re.sub(r'[^\w\-]', '_', cmd_basename)
                
                # Build the switch part (limited length)
                name_part = "_".join(switch_parts_for_filename)
                
                # Truncate switch part if too long
                max_switch_len = 30
                if len(name_part) > max_switch_len:
                    name_part = name_part[:max_switch_len]
                
                # Generate 8 random alphanumeric characters
                random_suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
                
                # Build the final filename with index for ordering
                filename = f"{cmd_basename}_{depth_indicator}_{crit_letters}_{combo_type}_{form_type}_{script_index:04d}_{random_suffix}_{name_part}.sh"
                filepath = pending_dir / filename
                
                # Write simple run script - just the command with metadata headers
                with open(filepath, 'w', newline='\n') as f:
                    f.write("#!/usr/bin/env bash\n")
                    f.write(f"# COMMAND: {full_command}\n")
                    f.write(f"# TYPE: {combo_type}\n")
                    f.write(f"# SWITCHES: {len(combo)}\n")
                    f.write(f"# CRITICALITY: {crit_letters}\n")
                    if combo_type == "invalid":
                        f.write("# EXPECT: non-zero exit code (should error due to conflicts)\n")
                    else:
                        f.write("# EXPECT: user-defined (valid combination)\n")
                    f.write("\n")
                    f.write(f"{full_command}\n")
                    f.write("exit $?\n")
                
                # Make executable
                os.chmod(filepath, 0o755)
                
                run_scripts.append({
                    'filename': filename,
                    'command': full_command,
                    'type': combo_type,
                    'form': form_type,
                    'switches': len(combo)
                })
                script_index += 1
    
    # Create manifest for verification
    with open(base_dir / "manifest.txt", 'w') as f:
        for run in run_scripts:
            f.write(f"{run['filename']}\t{run['command']}\t{run['type']}\n")
    
    # Create main runner script (handles all interactive logic)
    runner_path = base_dir / f"run_suite_{script_basename}.sh"
    with open(runner_path, 'w', newline='\n') as f:
        f.write("#!/usr/bin/env bash\n")
        f.write(f"# Main runner for {actual_command}\n")
        f.write(f"# Generated: {timestamp}\n")
        f.write("# The runner handles all interactive prompting and file organization\n")
        f.write("#\n")
        f.write("# This runner script:\n")
        f.write("# - Discovers all pending run scripts in the _pending_ directory\n")
        f.write("# - Extracts and displays the command from each script's header\n")
        f.write("# - In interactive mode, asks before each run (run/park/skip)\n")
        f.write("# - In batch mode, runs all pending scripts without prompting\n")
        f.write("# - Executes each run from the original working directory (where data files live)\n")
        f.write("# - Logs results and exit codes to results.csv\n")
        f.write("# - Moves successful runs to _completed_, failed runs stay in _pending_ for retry\n")
        f.write("# - Moves skipped runs to _skipped_\n")
        f.write("# - Verifies all expected runs from manifest.txt are accounted for\n")
        f.write("\n")
        f.write('# Reset terminal to a sane state (fixes issues from previous runs that may have left stdin in a bad state)\n')
        f.write('stty sane 2>/dev/null\n')
        f.write('# Force stdin to be attached to the terminal\n')
        f.write('exec < /dev/tty\n')
        f.write('\n')
        f.write('# Get the directory where this runner script lives\n')
        f.write('runner_dir="$(cd "$(dirname "$0")" && pwd)"\n')
        f.write('\n')
        f.write('echo "=== Suite Runner ===\n"\n')
        f.write(f'echo "Command under test: {actual_command}"\n')
        f.write('echo "Runner directory: $runner_dir"\n')
        f.write('echo "Original directory (where generator ran): ' + str(cwd) + '"\n')
        f.write('echo ""\n')
        f.write('\n')
        f.write(f'pending_dir="$runner_dir/_pending_{script_basename}"\n')
        f.write(f'completed_dir="$runner_dir/_completed_{script_basename}"\n')
        f.write(f'skipped_dir="$runner_dir/_skipped_{script_basename}"\n')
        f.write('\n')
        f.write('echo "Pending runs: $(ls "$pending_dir"/*.sh 2>/dev/null | wc -l)"\n')
        f.write('echo "Completed runs: $(ls "$completed_dir"/*.sh 2>/dev/null | wc -l)"\n')
        f.write('echo "Skipped runs: $(ls "$skipped_dir"/*.sh 2>/dev/null | wc -l)"\n')
        f.write('echo ""\n')
        f.write('\n')
        f.write('echo "Select mode:"\n')
        f.write('echo "1) Batch run (no prompts)"\n')
        f.write('echo "2) Interactive (prompt before each run)"\n')
        f.write('printf "Choice [1/2]: "\n')
        f.write('# Use read with direct terminal input to avoid stdin issues\n')
        f.write('read -r mode < /dev/tty\n')
        f.write('# Validate input\n')
        f.write('while [ "$mode" != "1" ] && [ "$mode" != "2" ]; do\n')
        f.write('    printf "Invalid choice. Please enter 1 or 2: "\n')
        f.write('    read -r mode < /dev/tty\n')
        f.write('done\n')
        f.write('echo ""\n')
        f.write('\n')
        f.write('echo "Run Name,Script,Complete Command,Returned Errorlevel" > results.csv\n')
        f.write('\n')
        f.write('run_mode="$mode"\n')
        f.write('\n')
        f.write('# Save original directory (where generator was run and data files live)\n')
        f.write(f'original_dir="{cwd}"\n')
        f.write('\n')
        f.write('# Run all pending runs\n')
        f.write('for run in "$pending_dir"/*.sh; do\n')
        f.write('    if [ ! -f "$run" ]; then continue; fi\n')
        f.write('    \n')
        f.write('    filename=$(basename "$run")\n')
        f.write('    \n')
        f.write('    # Extract the command from the run script header\n')
        f.write('    # The run scripts store the full command in a # COMMAND: line\n')
        f.write('    command_line=$(grep "^# COMMAND:" "$run" | sed "s/^# COMMAND: //")\n')
        f.write('    \n')
        f.write('    echo "========================================="\n')
        f.write('    echo "Run: $filename"\n')
        f.write('    echo "Command: $command_line"\n')
        f.write('    echo ""\n')
        f.write('    \n')
        f.write('    run_this=1\n')
        f.write('    \n')
        f.write('    if [ "$run_mode" = "2" ]; then\n')
        f.write('        echo "What should we do?"\n')
        f.write('        echo "  r / run   = Run this test"\n')
        f.write('        echo "  p / park  = Skip (stays in pending)"\n')
        f.write('        echo "  s / skip  = Skip (moves to skipped)"\n')
        f.write('        echo -n "Choice (r/p/s): "\n')
        f.write('        read choice\n')
        f.write('        # Convert to lowercase for case-insensitive comparison\n')
        f.write('        choice=$(echo "$choice" | tr "[:upper:]" "[:lower:]")\n')
        f.write('        \n')
        f.write('        case "$choice" in\n')
        f.write('            p|park)\n')
        f.write('                echo "Run parked (stays in pending)."\n')
        f.write('                echo ""\n')
        f.write('                run_this=0\n')
        f.write('                ;;\n')
        f.write('            s|skip)\n')
        f.write('                # Move to skipped folder without running\n')
        f.write('                mv "$run" "$skipped_dir/"\n')
        f.write('                echo "Run moved to skipped folder."\n')
        f.write('                echo ""\n')
        f.write('                run_this=0\n')
        f.write('                ;;\n')
        f.write('            *)\n')
        f.write('                # Default: run the test\n')
        f.write('                echo "Running..."\n')
        f.write('                echo ""\n')
        f.write('                ;;\n')
        f.write('        esac\n')
        f.write('    fi\n')
        f.write('    \n')
        f.write('    if [ "$run_this" = "1" ]; then\n')
        f.write('        # Run the test from original directory (where data files are)\n')
        f.write('        # pushd changes to the data directory, popd returns after the run\n')
        f.write('        pushd "$original_dir" > /dev/null\n')
        f.write('        bash "$run"\n')
        f.write('        exit_code=$?\n')
        f.write('        popd > /dev/null\n')
        f.write('        \n')
        f.write('        # Log result with timestamp and exit code\n')
        f.write('        echo "$(date +%Y%m%d_%H%M%S),$filename,$command_line,$exit_code,," >> results.csv\n')
        f.write('        \n')
        f.write('        if [ "$run_mode" = "2" ]; then\n')
        f.write('            echo ""\n')
        f.write('            echo "Exit code: $exit_code"\n')
        f.write('            echo -n "Assessment (PASS/FAIL/PARTIAL): "\n')
        f.write('            read assessment\n')
        f.write('            # Append assessment to the last line of the CSV\n')
        f.write('            sed -i "$ s/,$/,$assessment/" results.csv\n')
        f.write('        fi\n')
        f.write('        \n')
        f.write('        # Move based on exit code\n')
        f.write('        if [ $exit_code -eq 0 ]; then\n')
        f.write('            # Success - move to completed\n')
        f.write('            mv "$run" "$completed_dir/"\n')
        f.write('            echo "Run completed successfully."\n')
        f.write('        else\n')
        f.write('            # Failure - keep in pending for retry\n')
        f.write('            echo "Run failed with exit code $exit_code. Keeping in pending for retry."\n')
        f.write('            # Don\'t move the file - stays in pending\n')
        f.write('        fi\n')
        f.write('    fi\n')
        f.write('    \n')
        f.write('    echo ""\n')
        f.write('done\n')
        f.write('\n')
        f.write('# Check for missing runs (from manifest.txt)\n')
        f.write('# This verifies that all expected run scripts were accounted for\n')
        f.write('# If a script was manually deleted, it will appear here as a warning\n')
        f.write('if [ -f "$runner_dir/manifest.txt" ]; then\n')
        f.write('    while IFS=$'"'"'\t'"'"' read -r filename command type; do\n')
        f.write('        if [ ! -f "$completed_dir/$filename" ] && [ ! -f "$pending_dir/$filename" ]; then\n')
        f.write('            echo "WARNING: Expected run not found: $filename"\n')
        f.write('        fi\n')
        f.write('    done < "$runner_dir/manifest.txt"\n')
        f.write('fi\n')
        f.write('\n')
        f.write('echo ""\n')
        f.write('echo "Run complete!"\n')
        f.write('echo "Results saved in results.csv"\n')
        f.write('echo "Failed runs remain in _pending_ for retry."\n')
    
    os.chmod(runner_path, 0o755)
    
    print(f"\n=== Generation Complete ===")
    print(f"Generated {len(run_scripts)} run scripts in: {pending_dir}")
    print(f"Main runner: {runner_path}")
    print(f"\nNext steps:")
    print(f"1. cd {base_dir}")
    print(f"2. Review run scripts in _pending_{script_basename}/ (optional)")
    print(f"3. Run: ./run_suite_{script_basename}.sh")
    print(f"4. Choose batch or interactive mode")
    
    return base_dir

def main():
    """Main interactive flow with config file support"""
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description='Generate combinatorial CLI runs (test harness or batch job generator)',
        epilog='Save/load run configurations to avoid re-entering complex setups.'
    )
    parser.add_argument('--config', help='Load run configuration from JSON file')
    parser.add_argument('--save', action='store_true', help='Overwrite config file after any changes')
    parser.add_argument('--save-as', help='Save config to new file after generation')
    args = parser.parse_args()
    
    print("=" * 60)
    print("CLI Batch Generator - Combinatorial Run Generator (v2.2.5)")
    print("=" * 60)
    print(f"Current working directory: {Path.cwd()}")
    print("All run artifacts will be created here.")
    print("=" * 60)
    
    # Load config if provided
    script_name = None
    switches = None
    depth = None
    crit_filter = None
    config_path = None
    modify = False
    config_was_fixed = False
    
    if args.config:
        config_path = args.config
        script_name, switches, depth, crit_filter, config_was_fixed = load_config(config_path)
        print("\nConfig loaded. You can now modify settings if needed.\n")
        
        # Allow modification of loaded settings
        modify = get_user_input("Modify loaded settings? (y/n)", default="n").lower() == 'y'
        if modify == 'y':
            # Re-prompt for command name
            new_script = get_user_input("Command to run (press Enter to keep)", default=script_name)
            if new_script:
                script_name = new_script
            
            # Re-gather switches interactively
            print("\nRe-enter switches (modify as needed):")
            switches = gather_switches_interactive()
            
            # Re-prompt for depth and crit_filter
            depth = get_user_input("Run depth (1/2/3/all)", default=depth)
            crit_filter = get_user_input("Criticality filter (H/M/L)", default=crit_filter).upper()
            if crit_filter not in ['H', 'M', 'L']:
                crit_filter = 'M'
    
    # If no config loaded or we modified everything, do full interactive
    if script_name is None:
        print("\n=== Command Under Test ===")
        print("Enter the command to run. This can be ANY executable command:")
        print("")
        print("  - Simple command name: my_command")
        print("  - With interpreter: python script.py")
        print("  - With path: ../tools/deploy.sh")
        print("  - With flags: node --experimental-modules app.js")
        print("  - Quoted paths: 'python \"C:\\My Projects\\script.py\"'")
        print("")
        print("Note: The script will resolve script paths to absolute paths.")
        print("      Interpreters (python, node, etc.) are left as-is and found via PATH.")
        print("")
        script_name = get_user_input("Command to run", required=True)
        
        # Gather switches
        switches = gather_switches_interactive()
        
        if not switches:
            print("No switches defined. Exiting.")
            return
        
        # Display summary
        print("\n=== Switch Summary ===")
        for i, s in enumerate(switches, 1):
            print(f"{i}. {s}")
        
        # Get test parameters
        print("\n=== Run Parameters ===")
        
        # Count required switches
        required_count = sum(1 for s in switches if s.required)
        
        if required_count > 0:
            print(f"\nNote: {required_count} switch(es) marked as REQUIRED.")
            print(f"      Minimum run depth will be {required_count} (all required switches together).")
            if required_count > 3:
                print(f"  WARNING: {required_count} required switches means EVERY run will include all of them.")
                print(f"  This can cause combinatorial explosion if they have many values.")
            print("")
        
        print("Run Depth Explanation:")
        print("  The script generates combinations of switches at different depths:")
        print("")
        print("  - Singles (depth 1):")
        print("      Runs each switch individually")
        print("      Example: --verbose, --file data.txt, --quiet")
        print("")
        print("  - Pairs (depth 2):")
        print("      Runs all combinations of TWO switches")
        print("      Example: --verbose --file data.txt, --quiet --file data.txt")
        print("      This is often the 'sweet spot' - catches most interaction bugs")
        print("")
        print("  - Triples (depth 3):")
        print("      Runs all combinations of THREE switches")
        print("      Example: --verbose --file data.txt --quiet")
        print("")
        print("  - All combinations (depth = all):")
        print("      Runs EVERY possible combination (1 through N switches)")
        print("      WARNING: This can explode exponentially!")
        print("")
        print("  When switches are marked REQUIRED, the minimum depth is set to")
        print("  the number of required switches. For example, with 3 required")
        print("  switches, depth 3 generates only those 3 together. Depth 4")
        print("  generates those 3 plus one optional switch, and so on.")
        print("")
        
        # Determine recommended depth
        if required_count > 0:
            recommended = str(required_count)
            print("Recommended depth options:")
            print(f"  {required_count} = Run only the {required_count} required switches together")
            if required_count < len(switches):
                print(f"  {required_count + 1} = Required switches + 1 optional switch")
            print("  all = All combinations (required switches + all optional switches)")
        else:
            recommended = "2"
            print("Run depth options:")
            print("  1 = Singles only")
            print("  2 = Pairs only (recommended for most runs)")
            print("  3 = Triples only")
            print("  all = All combinations (1 through N)")
        
        depth = get_user_input("Select depth", default=recommended)
        
        # Criticality filter
        print("\nCriticality filter:")
        print("  This determines WHICH SWITCHES are included in the combinations:")
        print("")
        print("  H = High only")
        print("      ONLY switches you marked as High criticality will be run")
        print("      Medium and Low switches are completely ignored")
        print("      Use for quick smoke runs on core functionality")
        print("")
        print("  M = High + Medium")
        print("      Includes both High and Medium switches")
        print("      Low switches are excluded")
        print("      Good for standard run sets")
        print("")
        print("  L = All (High + Medium + Low)")
        print("      Includes EVERY switch regardless of criticality")
        print("      Use for full regression runs")
        print("")
        print("  Note: Criticality is a FILTER, not a priority within combinations.")
        print("        All included switches are treated equally in the combinations.")
        print("")
        crit_filter = get_user_input("Filter by criticality", default="M").upper()
        if crit_filter not in ['H', 'M', 'L']:
            crit_filter = 'M'
    
    # Validate switches before proceeding
    valid, fixed = validate_and_fix_switches(switches)
    if not valid:
        print("Switch validation failed. Please fix the errors and try again.")
        return
    
    # Offer to save config before generating runs
    if not args.config:
        save_choice = get_user_input("\nSave this configuration for future use? (y/n)", default="n").lower()
        if save_choice == 'y':
            # Extract basename from script_name (remove path and extension)
            cmd_basename = script_name.split('/')[-1].split('\\')[-1]
            if '.' in cmd_basename:
                cmd_basename = cmd_basename[:cmd_basename.rfind('.')]
            cmd_basename = re.sub(r'[^\w\-]', '_', cmd_basename)
            
            # Generate random suffix
            random_suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
            
            default_name = f"{cmd_basename}_config_{random_suffix}.json"
            save_path = get_user_input("Config filename", default=default_name)
            if not save_path:
                save_path = default_name
            save_config(save_path, script_name, switches, depth, crit_filter)
    else:
        # If we loaded a config and may have modified it, offer to save
        if modify or config_was_fixed:
            if config_was_fixed:
                print("\nNOTE: The loaded configuration had missing values that were filled in.")
            save_choice = get_user_input("\nSave updated configuration? (y/n)", default="y" if config_was_fixed else "n").lower() == 'y'
            if save_choice == 'y':
                if args.save and config_path:
                    save_config(config_path, script_name, switches, depth, crit_filter)
                elif args.save_as:
                    save_config(args.save_as, script_name, switches, depth, crit_filter)
                else:
                    # Extract basename from script_name
                    cmd_basename = script_name.split('/')[-1].split('\\')[-1]
                    if '.' in cmd_basename:
                        cmd_basename = cmd_basename[:cmd_basename.rfind('.')]
                    cmd_basename = re.sub(r'[^\w\-]', '_', cmd_basename)
                    
                    # Generate random suffix
                    random_suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
                    
                    default_name = f"{cmd_basename}_config_{random_suffix}.json"
                    save_path = get_user_input("Config filename", default=default_name)
                    if not save_path:
                        save_path = default_name
                    save_config(save_path, script_name, switches, depth, crit_filter)
    
    # Generate runs
    generate_run_scripts(switches, script_name, depth, crit_filter)
    
if __name__ == "__main__":
    main()