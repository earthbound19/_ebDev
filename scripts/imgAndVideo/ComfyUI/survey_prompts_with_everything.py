#!/usr/bin/env python3
"""
SCRIPT: survey_prompts_with_everything.py
VERSION: 2.2.0

DESCRIPTION:
    Launch Everything search windows to visually survey rendered images
    for each superprompt and metaprompt combination.
    
    Uses voidtools Everything to search the filesystem based on your
    output directory structure from comfyUIbatchRunner.py.
    
    The script iterates through:
        1. Each superprompt directory (sp000, sp001, etc.)
        2. Each metaprompt directory across ALL superprompts (mp000, mp001, etc.)
    
    For each search, it opens an Everything window showing only PNG files
    from the relevant directories.
    
    The script extracts prompt text directly from the pickle file - no
    separate superprompts.txt or metaprompts.txt files needed!

DEPENDENCIES:
    Python 3.6 or higher
    voidtools Everything installed and running
    Everything.exe location (configurable)

USAGE:
    # Survey superprompts and metaprompts from a state file
    python survey_prompts_with_everything.py \
        --state-file .comfyUIbatchRunner_render_state.pkl \
        --output-dir Y:\\path\\to\\ComfyUI\\output\\renders
    
    # With custom Everything path
    python survey_prompts_with_everything.py \
        --state-file state.pkl \
        --output-dir Y:\\output\\renders \
        --everything-path "C:\\Program Files\\Everything\\Everything.exe"
    
    # Survey only superprompts (skip metaprompts)
    python survey_prompts_with_everything.py \
        --state-file state.pkl \
        --output-dir Y:\\output\\renders \
        --skip-metaprompts

REQUIRED ARGUMENTS:
    --state-file FILE           State pickle file from comfyUIbatchRunner.py
    --output-dir PATH           Base output directory (where spXXX folders live)
                                Use backslashes and avoid spaces in paths.

OPTIONAL ARGUMENTS:
    --everything-path PATH      Path to Everything.exe (default: C:\\Program Files\\Everything\\Everything.exe)
    --skip-superprompts         Skip superprompt surveys
    --skip-metaprompts          Skip metaprompt surveys

WARNING:
    This script does NOT support spaces in paths. The command-line quoting
    required for spaces becomes too complex (nested quotes for cmd.exe and
    Everything). Keep your output directory path free of spaces.
    
    Example of what WILL NOT work:
        --output-dir "Y:\\My Renders\\output"
    
    Example of what works:
        --output-dir Y:\\renders\\output

NOTES:
    The script assumes your output directory structure is:
        {output_dir}\\spXXX\\mpYYY\\*.png
    
    It will open an Everything search window for each prompt combination.
    Press ENTER in the terminal after reviewing each search to continue.
    
    Everything must be installed and running for this script to work.
    
    Superprompt searches show all PNGs in a spXXX directory.
    Metaprompt searches show PNGs for a specific metaprompt across all spXXX directories.
"""

import argparse
import subprocess
import sys
import pickle
from collections import defaultdict
from pathlib import Path

def load_state_file(state_path):
    """Load state pickle file."""
    try:
        with open(state_path, 'rb') as f:
            state = pickle.load(f)
        return state
    except Exception as e:
        print(f"Error loading state file: {e}")
        return None

def extract_prompt_data_from_state(state):
    """Extract superprompt and metaprompt data directly from state file.
    
    Returns:
        tuple: (sp_data, mp_data)
        sp_data: {sp_idx: {'prompt': text, 'metaprompts': [mp_idx, ...]}}
        mp_data: {mp_idx: {'prompt': text, 'sp_indices': [sp_idx, ...]}}
    """
    sp_data = {}
    mp_data = defaultdict(lambda: {'prompt': None, 'sp_indices': set()})
    
    for combo in state:
        sp_idx = combo['superprompt_idx']
        sp_text = combo.get('superprompt', f"[Unknown superprompt {sp_idx}]")
        mp_idx = combo.get('metaprompt_idx', -1)
        mp_text = combo.get('metaprompt', '') if mp_idx >= 0 else None
        
        # Build superprompt data
        if sp_idx not in sp_data:
            sp_data[sp_idx] = {
                'prompt': sp_text,
                'metaprompts': set()
            }
        
        # Track which metaprompts belong to this superprompt
        if mp_idx >= 0:
            sp_data[sp_idx]['metaprompts'].add(mp_idx)
        
        # Build metaprompt data
        if mp_idx >= 0:
            if mp_data[mp_idx]['prompt'] is None:
                mp_data[mp_idx]['prompt'] = mp_text
            mp_data[mp_idx]['sp_indices'].add(sp_idx)
    
    # Convert sets to sorted lists
    for sp_idx in sp_data:
        sp_data[sp_idx]['metaprompts'] = sorted(sp_data[sp_idx]['metaprompts'])
    
    for mp_idx in mp_data:
        mp_data[mp_idx]['sp_indices'] = sorted(mp_data[mp_idx]['sp_indices'])
    
    return sp_data, dict(mp_data)

def build_superprompt_search(output_dir, sp_idx):
    """Build a search command for a single superprompt directory.
    
    Args:
        output_dir: Base output directory string (with backslashes)
        sp_idx: Superprompt index
    
    Returns:
        Search string for Everything
    """
    return f'.png {output_dir}\\sp{sp_idx:03d}'

def build_metaprompt_search(output_dir, mp_idx, sp_indices):
    """Build a search command for a metaprompt across multiple superprompts.
    
    Args:
        output_dir: Base output directory string (with backslashes)
        mp_idx: Metaprompt index
        sp_indices: List of superprompt indices that contain this metaprompt
    
    Returns:
        Search string for Everything
    """
    paths = [f'{output_dir}\\sp{sp_idx:03d}\\mp{mp_idx:03d}' for sp_idx in sp_indices]
    return '.png ' + ' | '.join(paths)

def open_everything(search_string, everything_path):
    """Open Everything with the given search string.
    
    Uses shell=True with outer quotes to preserve the search string.
    """
    try:
        cmd = f'"{everything_path}" -s "{search_string}"'
        subprocess.Popen(cmd, shell=True)
        return True
    except Exception as e:
        print(f"  Error launching Everything: {e}")
        return False

def truncate_prompt(prompt, max_len=80):
    """Truncate a prompt for display if too long."""
    if not prompt:
        return "[Empty prompt]"
    if len(prompt) <= max_len:
        return prompt
    return prompt[:max_len-3] + "..."

def main():
    parser = argparse.ArgumentParser(
        description='Survey prompts by opening Everything search windows',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('--state-file', required=True,
                       help='State pickle file from comfyUIbatchRunner.py')
    parser.add_argument('--output-dir', required=True,
                       help='Base output directory (use backslashes, avoid spaces)')
    parser.add_argument('--everything-path', 
                       default=r"C:\Program Files\Everything\Everything.exe",
                       help='Path to Everything.exe')
    parser.add_argument('--skip-superprompts', action='store_true',
                       help='Skip superprompt surveys')
    parser.add_argument('--skip-metaprompts', action='store_true',
                       help='Skip metaprompt surveys')
    
    args = parser.parse_args()
    
    # Validate Everything exists
    everything_path = args.everything_path
    if not Path(everything_path).exists():
        print(f"Error: Everything not found at {everything_path}")
        print("Please install Everything or specify correct path with --everything-path")
        sys.exit(1)
    
    # Use output_dir as-is - user must provide backslashes and avoid spaces
    output_dir = args.output_dir.rstrip('\\')
    
    # Load state file
    print(f"\n{'='*70}")
    print(f"Loading state file: {args.state_file}")
    print(f"{'='*70}\n")
    
    state = load_state_file(args.state_file)
    if state is None:
        sys.exit(1)
    
    # Extract prompt data directly from state file
    sp_data, mp_data = extract_prompt_data_from_state(state)
    
    # Survey superprompts
    if not args.skip_superprompts:
        print(f"{'='*70}")
        print(f"SURVEYING SUPERPROMPTS")
        print(f"{'='*70}\n")
        
        for sp_idx in sorted(sp_data.keys()):
            search_string = build_superprompt_search(output_dir, sp_idx)
            data = sp_data[sp_idx]
            
            # Display prompt information
            print(f"{'─'*70}")
            print(f"SUPERPROMPT sp{sp_idx:03d}")
            print(f"{'─'*70}")
            print(f"  Prompt: {data['prompt']}")
            print(f"  Path: {output_dir}\\sp{sp_idx:03d}")
            
            # Show which metaprompts exist for this superprompt
            if data['metaprompts']:
                mp_list = [f"mp{mp:03d}" for mp in data['metaprompts']]
                print(f"  Contains metaprompts: {', '.join(mp_list)}")
            else:
                print(f"  Contains: No metaprompt subdirectories (no_meta case)")
            
            print(f"\n  Search: {search_string}")
            print(f"  Opening Everything...")
            
            open_everything(search_string, everything_path)
            
            print(f"\n  Review the images in Everything, then press ENTER to continue...")
            input()
            print()
    
    # Survey metaprompts
    if not args.skip_metaprompts and mp_data:
        print(f"{'='*70}")
        print(f"SURVEYING METAPROMPTS (across all superprompts)")
        print(f"{'='*70}\n")
        
        for mp_idx in sorted(mp_data.keys()):
            data = mp_data[mp_idx]
            search_string = build_metaprompt_search(output_dir, mp_idx, data['sp_indices'])
            
            # Display prompt information
            print(f"{'─'*70}")
            print(f"METAPROMPT mp{mp_idx:03d}")
            print(f"{'─'*70}")
            print(f"  Metaprompt: {data['prompt']}")
            print(f"  Found in {len(data['sp_indices'])} superprompt directories:")
            
            # Show which superprompts contain this metaprompt (with truncated prompt text)
            for sp_idx in data['sp_indices'][:10]:
                if sp_idx in sp_data:
                    sp_prompt = truncate_prompt(sp_data[sp_idx]['prompt'])
                    print(f"    sp{sp_idx:03d}: {sp_prompt}")
                else:
                    print(f"    sp{sp_idx:03d}: {output_dir}\\sp{sp_idx:03d}\\mp{mp_idx:03d}")
            
            if len(data['sp_indices']) > 10:
                print(f"    ... and {len(data['sp_indices']) - 10} more superprompts")
            
            print(f"\n  Search: {search_string}")
            print(f"  Opening Everything...")
            
            open_everything(search_string, everything_path)
            
            print(f"\n  Review the images in Everything, then press ENTER to continue...")
            input()
            print()
    
    elif not args.skip_metaprompts and not mp_data:
        print(f"{'='*70}")
        print(f"NO METAPROMPTS FOUND")
        print(f"{'='*70}")
        print("The state file contains no metaprompts (all mp_idx = -1).")
        print("This typically means your metaprompts.txt was empty.")
        print("Skipping metaprompt survey.\n")
    
    print(f"{'='*70}")
    print(f"SURVEY COMPLETE")
    print(f"{'='*70}")

if __name__ == "__main__":
    main()