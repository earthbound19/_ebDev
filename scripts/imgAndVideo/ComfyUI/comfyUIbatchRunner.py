#!/usr/bin/env python3
"""
SCRIPT: comfyUIbatchRunner.py
VERSION: 1.5.0

DESCRIPTION:
    ComfyUI Batch Render Script
    Automates batch rendering through ComfyUI's API by generating all combinations
    of superprompts and metaprompts from text files. Features include resume
    capability, stratified sampling for preview, organized output directory
    structure, state persistence, and unique-untried-first prioritization.

    The script loads a template workflow (API format JSON), substitutes
    metaprompts into superprompt templates where '{}' placeholders appear,
    randomizes seeds, and sends each combination to a running ComfyUI server.

DEPENDENCIES:
    Python 3.6 or higher
    requests library (pip install requests)
    ComfyUI server running with API access enabled

USAGE:
    python comfyUIbatchRunner.py -w WORKFLOW.json -s 1 -m 1

REQUIRED ARGUMENTS:
    -w, --workflowfilename    Path to API-format workflow JSON file

OPTIONAL ARGUMENTS:
    -s, --superpromptiterations    Number of times to repeat each superprompt
                                   (default: 1)
    -m, --metapromptiterations     Number of times to repeat each metaprompt
                                   (default: 1)
    -p, --pause                    Pause seconds between renders (default: 90)
    -u, --url                      ComfyUI server URL (default: http://127.0.0.1:8188)
    -o, --outputdir                Base output directory (default: renders)
    -r, --resume                   Resume from global index number (validates bounds)
    --sample SAMPLE_RATE           Preview mode: render only a fraction of remaining combinations.
                                   Value between 0.0 and 1.0 (e.g., 0.1 = 10% of combinations).
                                   Uses stratified sampling (every Nth item) to ensure
                                   proportional representation across all prompt pairs.
                                   Completed renders are still marked in the pickle file.
                                   
                                   Use cases:
                                   - Quick visual validation before committing to full run
                                   - Generate representative subset for review
                                   - Test prompt quality without rendering everything
                                   
                                   Examples:
                                   --sample 0.05  (5% of combinations)
                                   --sample 0.25  (25% of combinations)
    --shuffle                      Randomize render order (ignores original sequence)
    --unique-untried-first         Two-stage prioritization of unique untried combinations:
                                   1. Never-rendered combos (0 iterations) come before
                                      already-rendered combos (pending iterations)
                                   2. Within each group, combos with untouched prompts
                                      (superprompt AND metaprompt never rendered in ANY combo)
                                      come before those with touched prompts
                                   Shuffling, if enabled, occurs within each of the 4 resulting
                                   subgroups to maintain priority while adding randomness.
    --superprompts FILE            Path to superprompts file (default: superprompts.txt)
    --metaprompts FILE             Path to metaprompts file (default: metaprompts.txt)
    --state-file FILE              Path to state pickle file (default: .comfyUIbatchRunner_render_state.pkl)

FILE REQUIREMENTS:
    superprompts.txt (or custom file)    - One template per line, use '{}' as metaprompt placeholder
    metaprompts.txt (or custom file)     - One metaprompt per line, inserted into '{}' placeholders
    
    If one file is empty and the other has content, the script treats the empty file
    as containing a single empty string, allowing rendering of only the non-empty file's
    prompts with no substitution.

NOTES:
    PROMPT FILE FORMAT:
        superprompts.txt contains prompt TEMPLATES with '{}' as a placeholder.
        Example: "expressive abstract {}, bold brushstrokes on textured paper"
        
        metaprompts.txt contains VALUES that replace '{}' in the template.
        Example: "vibrant crimson red"
        
        When combined, the script produces:
        "expressive abstract vibrant crimson red, bold brushstrokes on textured paper"
        
        Each line in both files is treated as a separate prompt. Empty lines are ignored.
        The script generates EVERY combination of superprompt template and metaprompt value.
        
        If metaprompts.txt is empty, each superprompt renders once with the '{}' placeholder
        removed (replaced with empty string).
        
        Example with 2 superprompts and 3 metaprompts = 6 total renders:
            Superprompt A + Metaprompt 1
            Superprompt A + Metaprompt 2
            Superprompt A + Metaprompt 3
            Superprompt B + Metaprompt 1
            Superprompt B + Metaprompt 2
            Superprompt B + Metaprompt 3

    UNIQUE-UNTRIED-FIRST MODE:
        When enabled, the script applies two-stage prioritization to the render queue:
        
        Stage 1 (Simple): Never-rendered combinations (0 iterations done) are prioritized
        over already-rendered combinations (≥1 iteration done but more pending due to
        -s or -m repetitions).
        
        Stage 2 (Complex): Within each group from Stage 1, combinations where BOTH the
        superprompt AND metaprompt have never been rendered in ANY combination
        (untouched prompts) are prioritized over those where either prompt has been
        rendered before (touched prompts).
        
        "Rendered" means a successful completion recorded in the state pickle file.
        Touch status is determined from the full history of completed renders across
        all combinations, not only the pending subset.
        
        Final queue order (highest to lowest priority):
        1. Never-rendered combos with untouched prompts
        2. Never-rendered combos with touched prompts
        3. Already-rendered combos with untouched prompts
        4. Already-rendered combos with touched prompts
        
        This ensures the most unique and unexplored combinations get rendered first,
        while still eventually covering all pending renders.
        
        When --shuffle is also used, shuffling occurs within each of the 4 subgroups
        to maintain priority order while adding randomness.

    RENDER STATE FILE (.comfyUIbatchRunner_render_state.pkl):
        Created automatically in the current working directory when the script runs.
        Contains a complete record of every combination (superprompt index, metaprompt index,
        completion status, seed used, timestamp, output path).
        
        This file allows you to resume an interrupted batch run.
        The file is NOT portable - if you move it to another machine or change your
        prompt files, the index mappings will break.
        
        If you lose or delete the state file, the script cannot know which renders
        are complete.
        
        IMPORTANT: Changing the iteration counts (-s or -m) after a state file exists
        will change the total number of combinations and the mapping of global indices,
        corrupting the state file. If you need to change iterations, start a fresh batch
        or delete the existing .pkl file.

    RESUME BEHAVIOR (with existing state pickle file):
        The --resume flag requires a valid state pickle file. If the state file is
        missing or corrupted, the script will treat all renders as pending and start
        from the given index (potentially re-rendering already completed work).
        
        With a valid pickle file present, the following behaviors apply:

        --resume with valid index within range:
            Loads completed status from pickle file, renders only pending indices
            greater than or equal to the resume index. Previously completed renders
            before the resume index are skipped.

        --resume with negative index (e.g., -r -5):
            Script exits immediately with error:
            "Error: Resume index -5 is negative. Must be >= 0"

        --resume with index exceeding maximum combination count:
            Script exits immediately with error:
            "Error: Resume index 999999 exceeds maximum index 2087. Valid range: 0 to 2087"

        --resume with index that is already marked completed:
            Script skips that index (not in pending list), finds next pending index
            greater than or equal to resume value. If no pending renders exist at or
            after the resume index, exits with error:
            "Error: No pending renders from index X onward. Either index X is already
            completed, or all subsequent renders are done"

        --resume with index that is pending (not yet rendered):
            Script renders from that index through the end of the combination list.

        Corrupted pickle file:
            Script prints warning: "Warning: Could not load state file: [error]"
            Continues as if no state file exists (as if all combinations are marked pending).

    OUTPUT DIRECTORY STRUCTURE AND FILENAMES:
        Images are saved to: ComfyUI/output/[outputdir]/spXXX_mpYYY/ where XXX is superprompt index
        and YYY is metaprompt index (zero-padded to 3 digits). If metaprompt is empty, "no_meta" is used.
        
        Filename pattern: <superprompt_sanitized>__<metaprompt_sanitized>__seed<random>_#####.png
        (Sanitization: removes non-alphanumeric characters, replaces spaces with underscores,
        truncates each part to 20 characters.)
        
        The -s and -m repetition parameters don't create separate subdirectories.
        All repetitions of the same superprompt + metaprompt pair go to the same folder.
        
        Example: If -s 2 and -m 3, renders 0-5 all go to sp000_mp000/
        (6 total renders in that folder)
        
        The output directory (-o) creates a subdirectory under ComfyUI's default output
        folder (typically ComfyUI/output/). Using an absolute path for -o will not work
        because ComfyUI restricts output to its own output folder; use relative paths only.

    WORKFLOW REQUIREMENTS:
        The workflow used for rendering must be exported in API format (not the UI format).
        The script expects:
        - A CLIPTextEncode node with title containing "Prompt Positive"
        - A KSampler node (basic KSampler; KSamplerAdvanced is not supported)
        - A SaveImage node (or any node with class_type "SaveImage")
        
        Negative prompts are not modified by this script. A negative prompt node is optional.

    INDEX NUMBERS AND RESUME:
        Each combination is assigned a global index number (0, 1, 2, ...) in the order
        they will be rendered. The console shows this number for every render:
        
            "--- Render 1/2088 (Global index: 0) ---"
            
        To resume after stopping, note the NEXT global index you want to render.
        If you stopped during index 1157, resume from 1157 (that render will re-run).
        If you stopped between renders, resume from the index of what wasn't finished.

    STOPPING AND RESUMING PROPERLY:
        To stop a running batch:
        1. With the terminal running the batch selected and active, Press Ctrl+C
        2. Wait for the script to exit cleanly
        3. Note the last "Global index" shown in the console
        4. To resume, add: -r [next_index]
        
        Example: If you see "Global index: 1156" and then stop, resume with -r 1157
        
        The script updates the pickle file to note every successful render (after the
        render completes), so you can stop at any time with minimal progress loss.
        However, interrupting during the pickle save (a very short window) could corrupt
        the state file. For safety, you may back up the .pkl file before resuming.

    CHANGING PROMPT FILES OR ITERATIONS:
        WARNING: If you add, remove, or reorder lines in superprompts.txt or metaprompts.txt
        after starting a batch, the index mapping will be completely different.
        
        Your existing state file will refer to indices that no longer match the intended
        prompts. This will lead to an untraceable state and unexpected results.
        
        Similarly, changing -s or -m (iteration counts) changes the total number of
        combinations and the order of global indices, also corrupting the state.
        
        If you need to change prompts or iterations mid-project:
        1. Complete or abandon your current batch
        2. Delete or move the existing .pkl state file
        3. Start a fresh batch with the new settings

    COMFYUI SERVER REQUIREMENTS:
        The ComfyUI server must be running before you start this script.
        Default address: http://127.0.0.1:8188
        Use -u to specify a different address and/or port.
        
        The server must have the workflow's checkpoint, LoRAs, ControlNet models, etc.
        already loaded or available.

    SEED BEHAVIOR:
        Each render gets a random seed between 1 and 2^32-1.
        Seeds are not sequential or based on the global index.
        The seed used for each render is saved in the state file but not displayed
        in the console output.

    NETWORK AND TIMEOUTS:
        Each HTTP request to ComfyUI has a 30-second timeout.
        If the server does not respond within 30 seconds, the render is marked as failed.
        (Failed renders will be retried if the script is interrupted and resumed, failed
        renders are retried.)
        In the case of a failed render during run, the script continues to the next render
        (the script does not retry the failed render).
        
        Slow renders (e.g., high resolution, many steps) are not affected by this timeout.
        The timeout only applies to the initial HTTP connection and response, not to
        the render duration itself.
        
        The script also polls ComfyUI's /queue endpoint. As long as the prompt_id remains
        in the queue (running or pending), the render timeout counter resets. This prevents
        false timeouts on genuinely long renders.

    TROUBLESHOOTING:
        - "ModuleNotFoundError: No module named 'requests'": Run pip install requests
        - "Workflow file not found": Check -w path, use absolute or relative path
        - "Could not find positive prompt node": Your workflow JSON is not API format
          or the CLIPTextEncode node title doesn't contain "Prompt Positive"
        - "Template file not found": superprompts.txt or metaprompts.txt missing
        - State file corruption: Delete the .pkl file and re-run (loses progress)

    COMFYUI NETWORK CONNECTION TROUBLESHOOTING:
        - "Connection refused": Nothing is listening on the specified port.
          ComfyUI server is not running, or is running on a different port.
        - "Timeout": Server responded too slowly (30 second timeout).
          Check server load or increase timeout value in script.
        - "No route to host" / "Network is unreachable": Wrong IP address or network issue.
        - "Name or service not known": DNS lookup failed. Use IP address instead of hostname.

    SAMPLE MODE WITH PRIORITIZATION AND SHUFFLING:
        When --sample is used together with --unique-untried-first or --shuffle, the sampling
        is applied to the final ordered queue (after prioritisation and subgroup shuffling).
        Stratified sampling (every Nth item) ensures that the proportion of each subgroup
        (e.g., never-rendered+untouched) is preserved in the preview.

EXAMPLES:
    # Full run of all superprompt and metaprompt combinations (one each)
    python comfyUIbatchRunner.py -w workflow.json -s 1 -m 1

    # Prioritize unique untried combinations
    python comfyUIbatchRunner.py -w workflow.json --unique-untried-first

    # Use custom prompt files
    python comfyUIbatchRunner.py -w workflow.json --superprompts my_super.txt --metaprompts my_meta.txt

    # Superprompts only (with empty metaprompts file)
    echo "" > empty.txt
    python comfyUIbatchRunner.py -w workflow.json --superprompts superduperprompts.txt --metaprompts empty.txt

    # Preview 10% of combinations with unique-untried-first and shuffle
    python comfyUIbatchRunner.py -w workflow.json --sample 0.1 --shuffle --unique-untried-first -p 10

    # Resume from a specific global index (requires existing pickle file)
    python comfyUIbatchRunner.py -w workflow.json -r 1157

    # Repeat each superprompt 2 times, each metaprompt 3 times
    python comfyUIbatchRunner.py -w workflow.json -s 2 -m 3

    # Custom server and output directory (relative to ComfyUI/output/)
    python comfyUIbatchRunner.py -w workflow.json -u http://192.168.1.100:8188 -o renders

CODE:
"""

# TODO: Implement atomic save for state pickle file (write to temp, then rename) to avoid corruption on interrupt.
# TODO: Add collision avoidance for sanitized filename prefixes (e.g., append a short hash of the original prompt).

import json
import random
import time
import argparse
import requests
import sys
import pickle
import re
from pathlib import Path
from datetime import datetime

class ComfyUIBatchRenderer:
    def __init__(self, server_url="http://127.0.0.1:8188", output_base_dir="renders"):
        self.server_url = server_url
        self.prompt_endpoint = f"{server_url}/prompt"
        self.history_endpoint = f"{server_url}/history"
        self.output_base_dir = Path(output_base_dir)

    def sanitize_for_filename(self, text, max_len=20):
        """Sanitize text for use in filenames.
        
        Args:
            text: String to sanitize
            max_len: Maximum length of the sanitized string
        
        Returns:
            Sanitized string safe for filenames
        """
        # Remove any non-alphanumeric, non-space, non-underscore, non-dash characters
        cleaned = re.sub(r'[^\w\s-]', '', text)
        # Replace spaces with underscores
        cleaned = cleaned.replace(' ', '_')
        # Remove multiple consecutive underscores
        cleaned = re.sub(r'_+', '_', cleaned)
        # Truncate
        return cleaned[:max_len]
        
    def load_workflow(self, workflow_path):
        """Load workflow JSON from file"""
        try:
            with open(workflow_path, 'r', encoding='utf-8') as f:
                workflow = json.load(f)
            print(f"Loaded workflow from: {workflow_path}")
            return workflow
        except FileNotFoundError:
            print(f"Error: Workflow file not found: {workflow_path}")
            sys.exit(1)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in workflow file: {e}")
            sys.exit(1)
    
    def load_templates_from_file(self, filename, allow_empty=False):
        """Load prompt templates from text file (one per line)
        
        Args:
            filename: Path to the file to load
            allow_empty: If True, empty file returns empty list instead of exiting
        
        Returns:
            List of prompt templates (may be empty if allow_empty=True)
        """
        templates = []
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                templates = [line.strip() for line in f if line.strip()]
            if not templates:
                if allow_empty:
                    print(f"Warning: {filename} is empty - will treat as single empty string")
                    return []
                else:
                    print(f"Error: {filename} is empty")
                    sys.exit(1)
            else:
                print(f"Loaded {len(templates)} templates from: {filename}")
            return templates
        except FileNotFoundError:
            if allow_empty:
                print(f"Warning: {filename} not found - will treat as empty")
                return []
            else:
                print(f"Error: Template file not found: {filename}")
                sys.exit(1)
    
    def load_metaprompts_from_file(self, filename, allow_empty=False):
        """Load metaprompts from text file (one per line)
        
        Args:
            filename: Path to the file to load
            allow_empty: If True, empty file returns empty list instead of exiting
        
        Returns:
            List of metaprompts (may be empty if allow_empty=True)
        """
        metaprompts = []
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                metaprompts = [line.strip() for line in f if line.strip()]
            if not metaprompts:
                if allow_empty:
                    print(f"Warning: {filename} is empty - will treat as single empty string")
                    return []
                else:
                    print(f"Error: {filename} is empty")
                    sys.exit(1)
            else:
                print(f"Loaded {len(metaprompts)} metaprompts from: {filename}")
            return metaprompts
        except FileNotFoundError:
            if allow_empty:
                print(f"Warning: {filename} not found - will treat as empty")
                return []
            else:
                print(f"Error: Metaprompt file not found: {filename}")
                sys.exit(1)
    
    def substitute_metaprompt(self, superprompt, metaprompt):
        """Substitute metaprompt into superprompt template.
        
        If superprompt has no '{}' placeholder and metaprompt is non-empty,
        issue a warning and return the superprompt unchanged (metaprompt ignored).
        
        If metaprompt is empty string, remove the '{}' placeholder entirely.
        
        Args:
            superprompt: Template string possibly containing '{}'
            metaprompt: String to substitute (may be empty)
        
        Returns:
            Final prompt string
        """
        # Check for missing placeholder when metaprompt is provided
        if '{}' not in superprompt and metaprompt and metaprompt != "":
            print(f"  Warning: Superprompt has no '{{}}' placeholder, metaprompt '{metaprompt[:50]}...' will be ignored")
            return superprompt
        
        # Handle empty metaprompt (remove placeholder)
        if metaprompt == "":
            # Remove the placeholder entirely
            return superprompt.replace('{}', '').strip()
        else:
            # Normal substitution
            return superprompt.replace('{}', metaprompt)
    
    def generate_combination_index(self, superprompts, metaprompts, superprompt_iterations, metaprompt_iterations):
        """Generate ordered list of all combinations with metadata
        
        Handles empty metaprompts by treating as a single empty string.
        """
        combinations = []
        
        # Handle empty metaprompts by treating as a single empty string
        effective_metaprompts = metaprompts if metaprompts else [""]
        
        for sp_idx, sp in enumerate(superprompts):
            for s_rep in range(superprompt_iterations):
                for mp_idx, mp in enumerate(effective_metaprompts):
                    for m_rep in range(metaprompt_iterations):
                        combinations.append({
                            'index': len(combinations),
                            'superprompt_idx': sp_idx,
                            'superprompt': sp,
                            'metaprompt_idx': mp_idx if metaprompts else -1,  # -1 indicates no metaprompt
                            'metaprompt': mp,
                            'superprompt_repetition': s_rep,
                            'metaprompt_repetition': m_rep,
                            'completed': False,
                            'seed': None,
                            'output_path': None,
                            'timestamp': None
                        })
        return combinations
    
    def load_state(self, combinations, state_file):
        """Load previous state if exists"""
        if Path(state_file).exists():
            try:
                with open(state_file, 'rb') as f:
                    saved_state = pickle.load(f)
                    # Restore completion status
                    for saved_item in saved_state:
                        if saved_item['index'] < len(combinations):
                            combinations[saved_item['index']]['completed'] = saved_item['completed']
                            combinations[saved_item['index']]['seed'] = saved_item.get('seed')
                            combinations[saved_item['index']]['output_path'] = saved_item.get('output_path')
                            combinations[saved_item['index']]['timestamp'] = saved_item.get('timestamp')
                    completed_count = sum(1 for c in combinations if c['completed'])
                    print(f"Loaded state: {completed_count} renders already completed")
            except Exception as e:
                print(f"Warning: Could not load state file: {e}")
        return combinations
    
    def save_state(self, combinations, state_file):
        """Save current state"""
        try:
            with open(state_file, 'wb') as f:
                pickle.dump(combinations, f)
        except Exception as e:
            print(f"Warning: Could not save state: {e}")
    
    def find_node_by_class_type(self, workflow, class_type, title_substring=None):
        """Find node IDs by class_type and optionally title substring"""
        matching_nodes = []
        for node_id, node_data in workflow.items():
            if node_data.get('class_type') == class_type:
                if title_substring:
                    title = node_data.get('_meta', {}).get('title', '')
                    if title_substring.lower() in title.lower():
                        matching_nodes.append(node_id)
                else:
                    matching_nodes.append(node_id)
        return matching_nodes
    
    def update_prompt_in_workflow(self, workflow, new_prompt, is_positive=True):
        """Update either positive or negative prompt in the workflow"""
        if is_positive:
            pos_nodes = self.find_node_by_class_type(workflow, "CLIPTextEncode", "Prompt Positive")
            if pos_nodes:
                node_id = pos_nodes[0]
                workflow[node_id]['inputs']['text'] = new_prompt
                print(f"Updated positive prompt (node {node_id})")
            else:
                print(f"Could not find positive prompt node")
        else:
            neg_nodes = self.find_node_by_class_type(workflow, "CLIPTextEncode", "Prompt Negative")
            if neg_nodes:
                node_id = neg_nodes[0]
                workflow[node_id]['inputs']['text'] = new_prompt
                print(f"Updated negative prompt (node {node_id})")
            else:
                print(f"Could not find negative prompt node")
    
    def update_seed_in_workflow(self, workflow, seed):
        """Update seed in KSampler node"""
        sampler_nodes = self.find_node_by_class_type(workflow, "KSampler")
        if sampler_nodes:
            node_id = sampler_nodes[0]
            workflow[node_id]['inputs']['seed'] = seed
            print(f"Updated seed to {seed} (node {node_id})")
        else:
            print(f"Could not find KSampler node")

    def update_output_node(self, workflow, output_subdir, filename_prefix=None):
        """Update SaveImage node to use organized subdirectory and custom prefix.
        
        Args:
            workflow: The workflow dictionary
            output_subdir: Relative path for the output subdirectory (e.g., "sp000/mp000")
            filename_prefix: Optional custom prefix for filenames (ComfyUI will still add _##### suffix)
        """
        save_nodes = self.find_node_by_class_type(workflow, "SaveImage")
        if save_nodes:
            node_id = save_nodes[0]
            # Build the full relative path: outputdir/sp000/mp000
            full_output_path = self.output_base_dir / output_subdir
            
            if 'subfolder' in workflow[node_id]['inputs']:
                # Use subfolder if node supports it
                workflow[node_id]['inputs']['subfolder'] = str(full_output_path)
                print(f"Set output subfolder: {full_output_path}")
            else:
                # For nodes without subfolder, modify filename_prefix to include path
                original_prefix = workflow[node_id]['inputs'].get('filename_prefix', 'ComfyUI')
                # Use custom prefix if provided, otherwise keep original
                if filename_prefix:
                    prefix = filename_prefix
                else:
                    prefix = original_prefix
                # ComfyUI interprets forward slashes as subdirectory separators
                workflow[node_id]['inputs']['filename_prefix'] = f"{full_output_path}/{prefix}"
                print(f"Set output prefix with path: {full_output_path}/{prefix}")

    def send_to_comfyui(self, workflow, render_timeout=600):
        """Send workflow to ComfyUI and monitor execution until completion or timeout.
        
        Polls /history for completion and /queue to detect if render is still alive.
        Resets timeout counter as long as prompt_id appears in /queue.
        
        Args:
            workflow: The workflow dictionary to send
            render_timeout: Maximum seconds to wait for a single render before assuming failure and submitting another render (default: 600)
        
        Returns:
            bool: True if render completed successfully, False otherwise
        """
        # Submit the job
        try:
            payload = {"prompt": workflow}
            response = requests.post(self.prompt_endpoint, json=payload, timeout=30)
            response.raise_for_status()
            result = response.json()
            prompt_id = result.get('prompt_id')
            if not prompt_id:
                print("Error: No prompt_id returned from ComfyUI")
                return False
            print(f"Sent to ComfyUI, prompt_id: {prompt_id}")
        except requests.exceptions.RequestException as e:
            print(f"Error sending workflow to ComfyUI: {e}")
            return False
        
        # Poll for completion
        history_url = f"{self.server_url}/history/{prompt_id}"
        queue_url = f"{self.server_url}/queue"
        start_time = time.time()
        poll_interval = 12
        last_alive_time = start_time
        
        while time.time() - start_time < render_timeout:
            # Check history first (completion)
            try:
                history_response = requests.get(history_url, timeout=10)
                if history_response.status_code == 200:
                    history_data = history_response.json()
                    if prompt_id in history_data:
                        # Render is complete - check for errors
                        prompt_history = history_data[prompt_id]
                        if prompt_history.get('status', {}).get('status_str') == 'error':
                            error_msg = prompt_history.get('status', {}).get('status', 'Unknown error')
                            print(f"Render {prompt_id} failed with error: {error_msg}")
                            return False
                        print(f"Render {prompt_id} completed successfully")
                        return True
            except requests.exceptions.RequestException as e:
                print(f"Warning: Could not check history for {prompt_id}: {e}")
            
            # Check queue to see if render is still alive
            try:
                queue_response = requests.get(queue_url, timeout=10)
                if queue_response.status_code == 200:
                    queue_data = queue_response.json()
                    # Check running queue
                    running_ids = [item[0] for item in queue_data.get('queue_running', []) if item]
                    pending_ids = [item[0] for item in queue_data.get('queue_pending', []) if item]
                    
                    if prompt_id in running_ids or prompt_id in pending_ids:
                        # Render is still alive - reset timeout
                        last_alive_time = time.time()
                        # Calculate effective timeout based on last alive signal
                        effective_elapsed = time.time() - last_alive_time
                        print(f"  Render {prompt_id} still in queue (running/pending), resetting timeout. Alive for {effective_elapsed:.0f}s")
                    elif prompt_id not in running_ids and prompt_id not in pending_ids:
                        # Not in queue and not in history - may have crashed silently
                        # Check if enough time has passed since last alive
                        if time.time() - last_alive_time > 60:
                            print(f"Render {prompt_id} disappeared from queue without completing - assuming failure")
                            return False
            except requests.exceptions.RequestException as e:
                print(f"Warning: Could not check queue status: {e}")
            
            time.sleep(poll_interval)
        
        # Timeout reached
        print(f"Error: Render {prompt_id} timed out after {render_timeout} seconds")
        return False

    def run_batch(self, workflow_path, superprompt_iterations, metaprompt_iterations, 
              pause_seconds=90, start_from=None, sample_rate=None, shuffle=False,
              render_timeout=600, superprompt_file="superprompts.txt", 
              metaprompt_file="metaprompts.txt", state_file=".comfyUIbatchRunner_render_state.pkl",
              unique_untried_first=False):
        
        # Load templates and metaprompts (allow empty for metaprompts)
        superprompts = self.load_templates_from_file(superprompt_file, allow_empty=False)
        metaprompts = self.load_metaprompts_from_file(metaprompt_file, allow_empty=True)
        
        if not superprompts:
            print("Error: Superprompts file must contain at least one entry")
            sys.exit(1)
        
        # Generate full combination index (handles empty metaprompts internally)
        combinations = self.generate_combination_index(
            superprompts, metaprompts, 
            superprompt_iterations, metaprompt_iterations
        )
        
        max_index = len(combinations) - 1
        
        # Validate resume index before doing anything else
        if start_from is not None:
            if start_from < 0:
                print(f"Error: Resume index {start_from} is negative. Must be >= 0")
                sys.exit(1)
            if start_from > max_index:
                print(f"Error: Resume index {start_from} exceeds maximum index {max_index}")
                print(f"Valid range: 0 to {max_index}")
                sys.exit(1)
        
        # Load previous state
        combinations = self.load_state(combinations, state_file)
        
        # Filter for incomplete renders
        pending = [c for c in combinations if not c['completed']]
        
        if not pending:
            print("All renders already completed")
            return
        
        # Apply resume filter (now safe because we validated start_from)
        if start_from is not None:
            pending = [c for c in pending if c['index'] >= start_from]
            if not pending:
                print(f"Error: No pending renders from index {start_from} onward")
                print(f"Either index {start_from} is already completed, or all subsequent renders are done")
                sys.exit(1)
            print(f"Resuming from index {start_from}, {len(pending)} renders remaining")
        
        # Apply unique-untried-first prioritization if requested
        if unique_untried_first:
            # Stage 1: Split by whether combo has ANY completed render (simple)
            never_rendered = [c for c in pending if not c['completed']]
            already_rendered = [c for c in pending if c['completed']]
            
            # Build sets of touched prompts from ALL combinations (not just pending)
            touched_superprompts = {c['superprompt_idx'] for c in combinations if c['completed']}
            touched_metaprompts = {c['metaprompt_idx'] for c in combinations if c['completed'] and c['metaprompt_idx'] >= 0}
            
            # Function to determine if a combo has untouched prompts
            def is_untouched_prompts(combo):
                sp_touched = combo['superprompt_idx'] in touched_superprompts
                mp_touched = combo['metaprompt_idx'] in touched_metaprompts if combo['metaprompt_idx'] >= 0 else False
                return not (sp_touched or mp_touched)
            
            # Stage 2: Split each group by prompt touch status
            never_untouched = [c for c in never_rendered if is_untouched_prompts(c)]
            never_touched = [c for c in never_rendered if not is_untouched_prompts(c)]
            already_untouched = [c for c in already_rendered if is_untouched_prompts(c)]
            already_touched = [c for c in already_rendered if not is_untouched_prompts(c)]
            
            # Shuffle each subgroup if requested
            if shuffle:
                random.shuffle(never_untouched)
                random.shuffle(never_touched)
                random.shuffle(already_untouched)
                random.shuffle(already_touched)
            
            # Combine in priority order
            pending = never_untouched + never_touched + already_untouched + already_touched
            
            print(f"Unique-untried-first mode: Enabled")
            print(f"  Never-rendered + untouched prompts: {len(never_untouched)}")
            print(f"  Never-rendered + touched prompts: {len(never_touched)}")
            print(f"  Already-rendered + untouched prompts: {len(already_untouched)}")
            print(f"  Already-rendered + touched prompts: {len(already_touched)}")
        
        # Apply sampling if requested (after prioritization)
        if sample_rate and sample_rate > 0 and sample_rate < 1:
            sample_step = int(1.0 / sample_rate)
            original_count = len(pending)
            sampled_indices = set(range(0, original_count, sample_step))
            pending = [pending[i] for i in sorted(sampled_indices)]
            print(f"Sampling mode: {sample_rate*100:.1f}% of remaining renders ({len(pending)} of {original_count} items)")
        
        # Shuffle if requested (and not already shuffled by unique-untried-first)
        if shuffle and not unique_untried_first:
            random.shuffle(pending)
            print("Shuffle mode: render order randomized")
        elif shuffle and unique_untried_first:
            print("Shuffle mode: Applied within unique-untried-first subgroups")
        
        total_renders = len(pending)
        
        print(f"\n{'='*70}")
        print(f"Batch Render")
        print(f"  Superprompts: {len(superprompts)}")
        print(f"  Metaprompts: {len(metaprompts) if metaprompts else 0} (treating empty as single empty string)")
        print(f"  Superprompt iterations: {superprompt_iterations}")
        print(f"  Metaprompt iterations: {metaprompt_iterations}")
        print(f"  Total combinations: {len(combinations)}")
        print(f"  Already completed: {len([c for c in combinations if c['completed']])}")
        print(f"  Pending renders: {total_renders}")
        print(f"  Pause between renders: {pause_seconds}s")
        print(f"  Output directory: {self.output_base_dir}")
        print(f"{'='*70}\n")
        
        # Track statistics
        successful_renders = 0
        failed_renders = 0
        
        for render_num, combo in enumerate(pending, 1):
            print(f"\n--- Render {render_num}/{total_renders} (Global index: {combo['index']}) ---")
            
            # Load fresh workflow for each render
            workflow = self.load_workflow(workflow_path)
            
            # Create organized output subdirectory
            if combo['metaprompt_idx'] >= 0:
                output_subdir = str(Path(f"sp{combo['superprompt_idx']:03d}") / f"mp{combo['metaprompt_idx']:03d}")
            else:
                output_subdir = str(Path(f"sp{combo['superprompt_idx']:03d}") / "no_meta")
            
            # Substitute metaprompt into template (handles empty metaprompt)
            final_prompt = self.substitute_metaprompt(combo['superprompt'], combo['metaprompt'])
            
            # Randomize seed
            random_seed = random.randint(1, 2**32 - 1)

            # Generate meaningful filename prefix
            safe_sp = self.sanitize_for_filename(combo['superprompt'], 20)
            if combo['metaprompt']:
                safe_mp = self.sanitize_for_filename(combo['metaprompt'], 20)
                filename_prefix = f"{safe_sp}__{safe_mp}__seed{random_seed}"
            else:
                filename_prefix = f"{safe_sp}__seed{random_seed}"
            
            print(f"  Superprompt [{combo['superprompt_idx']}]: {combo['superprompt'][:60]}...")
            if combo['metaprompt']:
                print(f"  Metaprompt [{combo['metaprompt_idx']}]: {combo['metaprompt']}")
            else:
                print(f"  Metaprompt: (none - empty string)")
            print(f"  Final prompt: {final_prompt[:100]}...")
            print(f"  Output folder: {output_subdir}")
            print(f"  Filename prefix: {filename_prefix}")
            
            # Update workflow
            self.update_prompt_in_workflow(workflow, final_prompt, is_positive=True)
            self.update_seed_in_workflow(workflow, random_seed)
            self.update_output_node(workflow, output_subdir, filename_prefix)
            
            # Send to ComfyUI with timeout monitoring
            success = self.send_to_comfyui(workflow, render_timeout=render_timeout)
            
            if success:
                successful_renders += 1
                combo['completed'] = True
                combo['seed'] = random_seed
                combo['timestamp'] = datetime.now().isoformat()
                combo['output_path'] = str(self.output_base_dir / output_subdir)
                # Save state after each successful render
                self.save_state(combinations, state_file)
            else:
                failed_renders += 1
            
            # Pause between renders (except after the last one)
            if render_num < total_renders:
                print(f"\nPausing for {pause_seconds} seconds...")
                time.sleep(pause_seconds)
        
        # Print summary
        print(f"\n{'='*70}")
        print(f"Batch Render Complete")
        print(f"  Successful renders: {successful_renders}")
        print(f"  Failed renders: {failed_renders}")
        print(f"  Total renders this session: {total_renders}")
        remaining = len([c for c in combinations if not c['completed']])
        if remaining > 0:
            print(f"  Remaining renders: {remaining}")
        print(f"{'='*70}\n")

def main():
    parser = argparse.ArgumentParser(description='ComfyUI Batch Render')
    parser.add_argument('-s', '--superpromptiterations', 
                       type=int, 
                       default=1,
                       help='Number of times to repeat each superprompt')
    parser.add_argument('-m', '--metapromptiterations', 
                       type=int, 
                       default=1,
                       help='Number of times to repeat each metaprompt')
    parser.add_argument('-w', '--workflowfilename', 
                       type=str, 
                       required=True,
                       help='Path to workflow JSON file (API format)')
    parser.add_argument('-u', '--url', 
                       type=str, 
                       default='http://127.0.0.1:8188',
                       help='ComfyUI server URL')
    parser.add_argument('-p', '--pause', 
                       type=int, 
                       default=90,
                       help='Pause seconds between renders')
    parser.add_argument('-r', '--resume', 
                       type=int, 
                       default=None,
                       help='Resume from global index number (validates bounds)')
    parser.add_argument('--sample', 
                       type=float, 
                       default=None,
                       help='Sample rate for preview (0.0-1.0, e.g., 0.1 = 10 percent)')
    parser.add_argument('--shuffle', 
                       action='store_true',
                       help='Randomize render order')
    parser.add_argument('--unique-untried-first', 
                       action='store_true',
                       help='Two-stage prioritization: first by never-rendered combos, '
                            'then by untouched prompts (superprompt+metaprompt never rendered in ANY combo)')
    parser.add_argument('-o', '--outputdir', 
                       type=str, 
                       default='renders',
                       help='Base output directory (default: renders)')
    parser.add_argument('--timeout', 
                       type=int, 
                       default=600,
                       help='Maximum seconds to wait for a single render before assuming failure '
                            'and submitting another render (default: 600)')
    parser.add_argument('--superprompts', 
                       type=str, 
                       default='superprompts.txt',
                       help='Path to superprompts file (default: superprompts.txt)')
    parser.add_argument('--metaprompts', 
                       type=str, 
                       default='metaprompts.txt',
                       help='Path to metaprompts file (default: metaprompts.txt)')
    parser.add_argument('--state-file', 
                       type=str, 
                       default='.comfyUIbatchRunner_render_state.pkl',
                       help='Path to state pickle file (default: .comfyUIbatchRunner_render_state.pkl)')
    
    args = parser.parse_args()
    
    # Validate inputs
    if args.superpromptiterations < 1 or args.metapromptiterations < 1:
        print("Error: Iterations must be at least 1")
        sys.exit(1)
    
    if args.sample and (args.sample <= 0 or args.sample > 1):
        print("Error: Sample rate must be between 0 and 1")
        sys.exit(1)
    
    # Check if workflow file exists
    workflow_path = Path(args.workflowfilename)
    if not workflow_path.exists():
        print(f"Error: Workflow file not found: {workflow_path}")
        sys.exit(1)
    
    # Create renderer and run batch
    renderer = ComfyUIBatchRenderer(server_url=args.url, output_base_dir=args.outputdir)
    renderer.run_batch(
        workflow_path=args.workflowfilename,
        superprompt_iterations=args.superpromptiterations,
        metaprompt_iterations=args.metapromptiterations,
        pause_seconds=args.pause,
        start_from=args.resume,
        sample_rate=args.sample,
        shuffle=args.shuffle,
        render_timeout=args.timeout,
        superprompt_file=args.superprompts,
        metaprompt_file=args.metaprompts,
        state_file=args.state_file,
        unique_untried_first=args.unique_untried_first
    )

if __name__ == "__main__":
    main()