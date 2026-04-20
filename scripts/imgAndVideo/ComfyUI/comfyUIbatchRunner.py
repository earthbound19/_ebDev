#!/usr/bin/env python3
"""
SCRIPT: comfyUIbatchRunner.py
VERSION: 2.2.9

DESCRIPTION:
    ComfyUI Batch Render Script
    Automates batch rendering through ComfyUI's API by generating all combinations
    of superprompts and metaprompts from text files. Features include resume
    capability, stratified sampling for preview, organized output directory
    structure, state persistence, and unique-untried-first prioritization.

    The script loads a template workflow (API format JSON), substitutes
    metaprompts into superprompt templates where '{}' placeholders appear,
    randomizes seeds, and sends each combination to a running ComfyUI server.

ADVANCED FEATURES
    The script always runs in a distributed architecture with a shared state file,
    supporting any number of ComfyUI hosts from 1 to N:
    
    - Single host: One worker thread processes renders sequentially
    - Multiple hosts: One worker thread per host processes renders in parallel
    - Multiple script instances: Run on different machines sharing a state file
      (requires shared filesystem like NFS)
    
    Use comma-separated URLs with -u to specify multiple hosts.
    - Render status tracking: 'pending', 'rendering', 'completed', 'failed'
    - Lock file mechanism for distributed state access
    - Heartbeat monitoring for stale 'rendering' entries

DEPENDENCIES:
    Python 3.6 or higher
    requests library (pip install requests)
    ComfyUI server running with API access enabled

USAGE:
    # Single host (one worker thread):
    python comfyUIbatchRunner.py -w WORKFLOW.json -s 1 -m 1
    
    # Multiple hosts (one worker thread per host):
    python comfyUIbatchRunner.py -w WORKFLOW.json -u "http://192.168.0.25:8188,http://192.168.0.25:8189"
    
    # Distributed workers on shared state file (run on multiple machines)
    # Machine 1: python comfyUIbatchRunner.py -w WORKFLOW.json -u http://192.168.0.25:8188 --state-file /shared/state.pkl
    # Machine 2: python comfyUIbatchRunner.py -w WORKFLOW.json -u http://192.168.0.25:8189 --state-file /shared/state.pkl

REQUIRED ARGUMENTS:
    -w, --workflowfilename    Path to API-format workflow JSON file

OPTIONAL ARGUMENTS:
    -s, --superpromptiterations    Number of times to repeat each superprompt
                                   (default: 1)
    -m, --metapromptiterations     Number of times to repeat each metaprompt
                                   (default: 1)
    -p, --pause                    Pause seconds between renders (default: 90)
    -u, --url                      ComfyUI server URL. For multiple hosts, use 
                                   comma-separated: http://192.168.0.25:8188,http://192.168.0.25:8189
                                   (default: http://127.0.0.1:8188)
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
    --heartbeat-interval SECONDS   Heartbeat interval for distributed mode (default: 30)
    --timeout SECONDS              Maximum seconds to wait for a single render (default: 600)

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

    DISTRIBUTED MODE (Multi-Host):
        When -u contains comma-separated URLs, the script automatically runs in
        distributed multi-host mode. Features include:
        
        - Load balancing: Distributes renders across all healthy hosts
        - Health checking: Periodically checks each host's /queue endpoint
        - Concurrency control: Limits active renders per host (prevents GPU OOM)
        - Shared state: All workers share the same pickle file (requires shared storage)
        - Automatic failover: Failed renders return to queue for other workers
        - Heartbeat system: Prevents stale locks from blocking progress
        
        To run multiple workers on different machines:
        1. Place the state file on shared storage (NFS, EFS, etc.)
        2. Run the script on each machine with the same --state-file path
        3. Each worker will automatically claim and process pending renders
        
        Example distributed setup:
        # On machine A (GPU server 1)
        python comfyUIbatchRunner.py -w workflow.json \\
            -u http://192.168.1.10:8188 \\
            --state-file /shared/network/drive/render_state.pkl
        
        # On machine B (GPU server 2)
        python comfyUIbatchRunner.py -w workflow.json \\
            -u http://192.168.1.11:8188 \\
            --state-file /shared/network/drive/render_state.pkl
        
        # Single machine managing multiple ComfyUI instances on different hosts;
        # list all hosts in -u, separated by commas (note here they use different
        # ports as required (it seems?) by ComfyUI):
        python comfyUIbatchRunner.py -w workflow.json \\
            -u "http://192.168.0.1:8188,http://192.168.0.2:8189,http://192.168.0.3:8190"

    RENDER STATE FILE (.comfyUIbatchRunner_render_state.pkl):
        Created automatically in the current working directory when the script runs.
        Contains a complete record of every combination (superprompt index, metaprompt index,
        completion status, seed used, timestamp, output path, worker_id, status).
        
        This file allows you to resume an interrupted batch run or run distributed workers.
        The file is NOT portable - if you move it to another machine or change your
        prompt files, the index mappings will break.
        
        If you lose or delete the state file, the script cannot know which renders
        are complete.
        
        IMPORTANT: Changing the iteration counts (-s or -m) after a state file exists
        will change the total number of combinations and the mapping of global indices,
        corrupting the state file. If you need to change iterations, start a fresh batch
        or delete the existing .pkl file.

        BACKUP STATE FILES:
            The script automatically creates a backup of the state file every 25
            completed renders. Backup files are named:
            {state_file}.backup_{completed_count}

            For example: .comfyUIbatchRunner_render_state.pkl.backup_2411

            The number is the count of completed renders at the time of backup,
            not a global index. This makes it easy to identify the most recent
            backup even when using --shuffle (which randomizes render order).

            Backups are created in the same directory as the state file.

            The companion script merge_partialComfyUI_batches.py can be used to
            update a backup state file to include the state of current renders
            in case the production state file becomes corrupted. See the
            DISASTER RECOVERY comment in that script. It can also be used to
            merge fragmented or disparate batch runs with the same prompts etc.
            into a state file.

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

    # Multi-host mode - single instance managing multiple ComfyUI servers
    python comfyUIbatchRunner.py -w workflow.json -u "http://192.168.1.10:8188,http://192.168.1.11:8188"

    # Distributed workers using shared storage
    # Worker 1: python comfyUIbatchRunner.py -w workflow.json -u http://192.168.0.1:8188 --state-file /nfs/shared_state.pkl
    # Worker 2: python comfyUIbatchRunner.py -w workflow.json -u http://192.168.0.2:8189 --state-file /nfs/shared_state.pkl

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
import threading
import uuid
import socket
import os
import shutil
from pathlib import Path
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict, Optional, Tuple

class DistributedState:
    """Manages shared state with locking for distributed access across multiple workers"""
    
    def __init__(self, state_file, worker_id=None, lock_timeout=30):
        self.state_file = Path(state_file)
        self.lock_file = self.state_file.with_suffix('.lock')
        self.worker_id = worker_id or f"{socket.gethostname()}:{os.getpid()}:{uuid.uuid4().hex[:8]}"
        self.lock_timeout = lock_timeout
        self._lock_acquired = False
        self._refresh_thread = None
        self._stop_refresh = threading.Event()
    
    def _refresh_loop(self):
        """Background thread that refreshes lock timestamp to prevent staleness"""
        while not self._stop_refresh.is_set():
            if self._lock_acquired and self.lock_file.exists():
                try:
                    with open(self.lock_file, 'w') as f:
                        json.dump({'worker_id': self.worker_id, 'timestamp': time.time()}, f)
                except Exception:
                    pass  # Non-critical, best effort
            time.sleep(15)  # Refresh every 15 seconds
    
    def start_lock_refresh(self):
        """Start background thread to refresh lock periodically"""
        if self._refresh_thread is None or not self._refresh_thread.is_alive():
            self._stop_refresh.clear()
            self._refresh_thread = threading.Thread(target=self._refresh_loop, daemon=True)
            self._refresh_thread.start()
    
    def stop_lock_refresh(self):
        """Stop background lock refresh thread"""
        self._stop_refresh.set()
        if self._refresh_thread:
            self._refresh_thread.join(timeout=5)
    
    def acquire_lock(self, timeout=60):
        """Acquire lock file with timeout to prevent deadlocks"""
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                # Check for stale lock (older than lock_timeout seconds)
                if self.lock_file.exists():
                    lock_age = time.time() - self.lock_file.stat().st_mtime
                    if lock_age > self.lock_timeout:
                        print(f"Removing stale lock (age: {lock_age:.0f}s)")
                        try:
                            self.lock_file.unlink()
                        except PermissionError:
                            pass
                
                # Create lock file - try multiple methods
                lock_data = {
                    'worker_id': self.worker_id,
                    'timestamp': time.time()
                }
                
                # Method 1: Exclusive creation (most atomic)
                try:
                    with open(self.lock_file, 'x') as f:
                        f.write(json.dumps(lock_data))
                    self._lock_acquired = True
                    self.start_lock_refresh()
                    return True
                except FileExistsError:
                    pass
                
                # Method 2: Check if we already own it
                if self.lock_file.exists():
                    try:
                        with open(self.lock_file, 'r') as f:
                            existing = json.load(f)
                        if existing.get('worker_id') == self.worker_id:
                            # Refresh the lock
                            with open(self.lock_file, 'w') as f:
                                f.write(json.dumps(lock_data))
                            self._lock_acquired = True
                            self.start_lock_refresh()
                            return True
                    except:
                        pass
                
                time.sleep(1)
            except Exception as e:
                time.sleep(1)
        
        return False
    
    def release_lock(self):
        """Release lock file and stop refresh thread"""
        self.stop_lock_refresh()
        if self._lock_acquired and self.lock_file.exists():
            try:
                self.lock_file.unlink()
            except:
                pass
        self._lock_acquired = False
    
    def load_state(self, combinations_template=None):
        """Load state from pickle file with proper error handling"""
        if not self.state_file.exists():
            return combinations_template if combinations_template else []
        
        try:
            with open(self.state_file, 'rb') as f:
                state = pickle.load(f)
            return state
        except Exception as e:
            print(f"Warning: Could not load state: {e}")
            return combinations_template if combinations_template else []
    
    def save_state(self, state):
        """Save state atomically using temporary file with multiple fallback strategies"""
        temp_file = self.state_file.with_suffix('.tmp')
        
        try:
            # Write to temp file
            with open(temp_file, 'wb') as f:
                pickle.dump(state, f)
                f.flush()
                os.fsync(f.fileno())
            
            # Try atomic replace (works on Unix, Windows with replace())
            try:
                temp_file.replace(self.state_file)
                return True
            except (OSError, PermissionError) as e:
                print(f"  Atomic replace failed: {e}, trying fallback...")
                
                # Fallback 1: Try rename
                try:
                    os.rename(temp_file, self.state_file)
                    return True
                except OSError:
                    pass
                
                # Fallback 2: Copy then delete
                try:
                    shutil.copy2(temp_file, self.state_file)
                    temp_file.unlink()
                    return True
                except Exception:
                    pass
                
                # Fallback 3: Direct write (no atomicity, but better than nothing)
                try:
                    with open(self.state_file, 'wb') as f:
                        pickle.dump(state, f)
                    # Clean up temp file if it exists
                    if temp_file.exists():
                        temp_file.unlink()
                    return True
                except Exception:
                    pass
                
                raise Exception("All save strategies failed")
                
        except Exception as e:
            print(f"Error saving state: {e}")
            # Clean up temp file if it exists
            if temp_file.exists():
                try:
                    temp_file.unlink()
                except:
                    pass
            return False
    
    def update_render_status(self, combo_index, status, **kwargs):
        """Update status of a single render with lock acquisition"""
        if not self.acquire_lock():
            print(f"Could not acquire lock for status update")
            return False
        
        try:
            state = self.load_state()
            if combo_index < len(state):
                state[combo_index]['status'] = status
                state[combo_index]['worker_id'] = self.worker_id
                state[combo_index]['last_update'] = datetime.now().isoformat()
                for key, value in kwargs.items():
                    state[combo_index][key] = value
                self.save_state(state)
            return True
        finally:
            self.release_lock()

    def claim_next_pending(self, heartbeat_interval=60, shuffle=False, unique_untried_first=False):
        """Claim the next pending render for this worker atomically
        
        Supports three modes:
        1. Default (shuffle=False, unique_untried_first=False): Returns first pending render (index order)
        2. Shuffle (shuffle=True): Returns random pending render
        3. Unique-untried-first (unique_untried_first=True): Returns highest priority pending render based on:
        - Priority 1: Never-rendered combos with untouched prompts
        - Priority 2: Never-rendered combos with touched prompts  
        - Priority 3: Already-rendered combos with untouched prompts
        - Priority 4: Already-rendered combos with touched prompts
        
        Args:
            heartbeat_interval: Seconds after which a 'rendering' entry is considered stale
            shuffle: If True, randomly select from pending renders (overrides priority ordering)
            unique_untried_first: If True, use priority ordering instead of index order
        
        Returns:
            The claimed combo dictionary, or None if no pending renders available
        """
        if not self.acquire_lock():
            return None
        
        try:
            state = self.load_state()
            
            # Clean up stale 'rendering' entries (workers that died without updating heartbeat)
            now = datetime.now()
            for combo in state:
                if combo.get('status') == 'rendering':
                    last_update = datetime.fromisoformat(combo.get('last_update', '2000-01-01'))
                    if (now - last_update).total_seconds() > heartbeat_interval * 2:
                        print(f"Cleaning stale render {combo['index']} from worker {combo.get('worker_id')}")
                        combo['status'] = 'pending'
                        combo['worker_id'] = None
            
            # Find all pending renders
            pending = []
            for combo in state:
                if combo.get('status') == 'pending' or ('status' not in combo and not combo.get('completed')):
                    pending.append(combo)
            
            if not pending:
                return None
            
            # Select which pending render to claim
            if shuffle:
                # Mode 1: Random selection (overrides priority)
                import random
                combo = random.choice(pending)
            elif unique_untried_first:
                # Mode 2: Priority ordering based on render history and prompt touch status
                
                # Build sets of touched prompts from completed renders
                touched_superprompts = {c['superprompt_idx'] for c in state if c.get('status') == 'completed'}
                touched_metaprompts = {c['metaprompt_idx'] for c in state if c.get('status') == 'completed' and c['metaprompt_idx'] >= 0}
                
                def get_priority(combo):
                    """Calculate priority level (lower number = higher priority)"""
                    # Check if this combo has ever been completed
                    has_been_rendered = combo.get('status') == 'completed' or combo.get('completed', False)
                    
                    # Check if prompts are untouched
                    sp_touched = combo['superprompt_idx'] in touched_superprompts
                    mp_touched = combo['metaprompt_idx'] in touched_metaprompts if combo['metaprompt_idx'] >= 0 else False
                    is_untouched = not (sp_touched or mp_touched)
                    
                    # Priority levels:
                    # Level 0: Never rendered + untouched prompts (highest)
                    # Level 1: Never rendered + touched prompts
                    # Level 2: Already rendered + untouched prompts
                    # Level 3: Already rendered + touched prompts (lowest)
                    if not has_been_rendered:
                        return 0 if is_untouched else 1
                    else:
                        return 2 if is_untouched else 3
                
                # Sort pending by priority (lower number first)
                pending.sort(key=get_priority)
                combo = pending[0]
            else:
                # Mode 3: Default - first in list (original index order)
                combo = pending[0]
            
            # Claim the selected render
            combo['status'] = 'rendering'
            combo['worker_id'] = self.worker_id
            combo['claimed_at'] = datetime.now().isoformat()
            combo['last_update'] = combo['claimed_at']
            self.save_state(state)
            return combo
        finally:
            self.release_lock()

    def heartbeat(self, combo_index):
        """Update heartbeat for currently rendering item to prevent stale lock cleanup"""
        if not self.acquire_lock():
            return
        
        try:
            state = self.load_state()
            if combo_index < len(state) and state[combo_index].get('worker_id') == self.worker_id:
                state[combo_index]['last_update'] = datetime.now().isoformat()
                self.save_state(state)
        finally:
            self.release_lock()

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
            
            # FIX: Convert Windows backslashes to forward slashes for ComfyUI
            subfolder_str = str(full_output_path).replace('\\', '/')
            
            if 'subfolder' in workflow[node_id]['inputs']:
                # Use subfolder if node supports it
                workflow[node_id]['inputs']['subfolder'] = subfolder_str
                print(f"Set output subfolder: {subfolder_str}")
            else:
                # For nodes without subfolder, modify filename_prefix to include path
                original_prefix = workflow[node_id]['inputs'].get('filename_prefix', 'ComfyUI')
                # Use custom prefix if provided, otherwise keep original
                if filename_prefix:
                    prefix = filename_prefix
                else:
                    prefix = original_prefix
                # ComfyUI interprets forward slashes as subdirectory separators
                workflow[node_id]['inputs']['filename_prefix'] = f"{subfolder_str}/{prefix}"
                print(f"Set output prefix with path: {subfolder_str}/{prefix}")

    def send_to_comfyui(self, workflow, render_timeout=600, server_url=None):
        """Send workflow to ComfyUI and monitor execution until completion or timeout.
        
        Polls /history for completion and /queue to detect if render is still alive.
        Resets timeout counter as long as prompt_id appears in /queue.
        
        Args:
            workflow: The workflow dictionary to send
            render_timeout: Maximum seconds to wait for a single render before assuming failure and submitting another render (default: 600)
            server_url: Optional override for server URL (used by MultiHostManager)
        
        Returns:
            bool: True if render completed successfully, False otherwise
        """
        url = server_url or self.server_url
        prompt_endpoint = f"{url}/prompt"
        history_endpoint = f"{url}/history"
        queue_url = f"{url}/queue"
        
        # Submit the job
        try:
            payload = {"prompt": workflow}
            response = requests.post(prompt_endpoint, json=payload, timeout=30)
            response.raise_for_status()
            result = response.json()
            prompt_id = result.get('prompt_id')
            if not prompt_id:
                print(f"Error: No prompt_id returned from {url}")
                return False
            print(f"Sent to {url}, prompt_id: {prompt_id}")
        except requests.exceptions.RequestException as e:
            print(f"Error sending workflow to {url}: {e}")
            return False
        
        # Poll for completion
        start_time = time.time()
        poll_interval = 4
        last_alive_time = start_time
        
        while time.time() - start_time < render_timeout:
            # Check history first (completion)
            try:
                history_response = requests.get(f"{history_endpoint}/{prompt_id}", timeout=10)
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

    def run_batch_distributed(self, workflow_path, superprompt_iterations, metaprompt_iterations,
                            pause_seconds=90, render_timeout=600, superprompt_file="superprompts.txt",
                            metaprompt_file="metaprompts.txt", state_file=".comfyUIbatchRunner_render_state.pkl",
                            heartbeat_interval=30, multi_host_urls=None,
                            shuffle=False, unique_untried_first=False, sample_rate=None, start_from=None):
        """Distributed mode - one thread per host, each completely independent
        
        This mode runs one independent worker thread per ComfyUI host. Each thread:
        1. Claims a pending render from the shared state file
        2. Renders it on its dedicated host
        3. Waits for completion (with pause for GPU cooldown)
        4. Updates the state file
        5. Loops to claim the next render
        
        All ordering features (shuffle, unique-untried-first, sample, resume) are applied
        when generating the initial state file, before any rendering begins.
        
        Args:
            workflow_path: Path to API-format workflow JSON file
            superprompt_iterations: Number of times to repeat each superprompt
            metaprompt_iterations: Number of times to repeat each metaprompt
            pause_seconds: Pause between renders on each host (GPU cooldown)
            render_timeout: Maximum seconds to wait for a single render
            superprompt_file: Path to superprompts text file
            metaprompt_file: Path to metaprompts text file
            state_file: Path to state pickle file for distributed coordination
            heartbeat_interval: Seconds between heartbeat updates
            multi_host_urls: List of ComfyUI host URLs (one thread per host)
            shuffle: Randomize render order
            unique_untried_first: Prioritize never-rendered combos and untouched prompts
            sample_rate: Fraction of combinations to render (0.0-1.0)
            start_from: Resume from global index number
        """
        
        # Load prompts from files
        superprompts = self.load_templates_from_file(superprompt_file, allow_empty=False)
        metaprompts = self.load_metaprompts_from_file(metaprompt_file, allow_empty=True)
        
        if not superprompts:
            print("Error: Superprompts file must contain at least one entry")
            sys.exit(1)
        
        # Initialize distributed state manager for file locking
        dist_state = DistributedState(state_file)

        import queue
        state_update_queue = queue.Queue()
        stop_state_writer = threading.Event()

        def state_writer_thread():
            """Single thread to handle all state file writes with atomic saves and periodic backups"""
            write_count = 0  # Counter for tracking writes for backup
            
            def is_file_locked(filepath):
                """Check if a file is locked by another process (Windows friendly)"""
                if not os.path.exists(filepath):
                    return False
                try:
                    # Try to open for append (non-modifying)
                    with open(filepath, 'a'):
                        pass
                    return False
                except (OSError, PermissionError):
                    return True
            
            def is_state_file_corrupt(filepath):
                """Check if a state pickle file can be read (basic corruption check)"""
                if not os.path.exists(filepath):
                    return False
                try:
                    with open(filepath, 'rb') as f:
                        pickle.load(f)
                    return False  # Successfully loaded, not corrupt
                except Exception:
                    return True   # Any error means corrupt
            
            while not stop_state_writer.is_set():
                try:
                    update = state_update_queue.get(timeout=1)
                    if update is None:  # Poison pill
                        break
                    
                    combo_index, status, kwargs = update
                    
                    # Single-threaded write with lock
                    if dist_state.acquire_lock(timeout=30):
                        try:
                            with open(state_file, 'rb') as f:
                                state = pickle.load(f)
                            
                            if combo_index < len(state):
                                state[combo_index]['status'] = status
                                state[combo_index]['worker_id'] = dist_state.worker_id
                                state[combo_index]['last_update'] = datetime.now().isoformat()
                                for key, value in kwargs.items():
                                    state[combo_index][key] = value
                                
                                # Atomic write with retries for Windows file locking
                                temp_file = state_file + '.tmp'
                                max_attempts = 30  # Will retry for up to ~1 hour
                                retry_delay = 2    # Start with 2 seconds
                                save_success = False
                                
                                for attempt in range(max_attempts):
                                    try:
                                        # Check if target file is locked before trying
                                        if os.path.exists(state_file) and is_file_locked(state_file):
                                            wait_time = min(retry_delay * (1.5 ** attempt), 120)
                                            if attempt < 5:
                                                print(f"  State file locked - waiting {wait_time:.0f}s...")
                                            time.sleep(wait_time)
                                            continue
                                        
                                        # Write to temp file
                                        with open(temp_file, 'wb') as f:
                                            pickle.dump(state, f)
                                            f.flush()
                                            os.fsync(f.fileno())
                                        
                                        # Verify temp file is valid
                                        with open(temp_file, 'rb') as test_f:
                                            verified_state = pickle.load(test_f)
                                        if len(verified_state) != len(state):
                                            raise ValueError(f"State length mismatch: saved {len(verified_state)} vs expected {len(state)}")
                                        
                                        # Try atomic replace
                                        os.replace(temp_file, state_file)
                                        
                                        # Post-save verification
                                        with open(state_file, 'rb') as verify_f:
                                            final_state = pickle.load(verify_f)
                                        if len(final_state) != len(state):
                                            raise ValueError("Final state length mismatch")
                                        
                                        save_success = True
                                        break  # Success
                                        
                                    except (OSError, PermissionError) as e:
                                        # File locking conflict - wait and retry
                                        wait_time = min(retry_delay * (1.5 ** attempt), 120)
                                        
                                        if attempt < 5:
                                            print(f"  Save attempt {attempt + 1} failed: {e}")
                                            print(f"  Waiting {wait_time:.0f}s before retry...")
                                        elif attempt == 5:
                                            print(f"  File still locked - will keep retrying every ~{wait_time:.0f}s...")
                                        
                                        time.sleep(wait_time)
                                        
                                    except Exception as verify_error:
                                        print(f"Temp file invalid - skipping write: {verify_error}")
                                        if os.path.exists(temp_file):
                                            os.remove(temp_file)
                                        break
                                
                                if not save_success:
                                    # Critical failure - check if state file is corrupted
                                    print(f"\n{'='*70}")
                                    print(f"CRITICAL ERROR: Failed to save state file after {max_attempts} attempts")
                                    print(f"{'='*70}")
                                    
                                    if is_state_file_corrupt(state_file):
                                        print(f"  The existing state file is CORRUPTED.")
                                        print(f"  Your render progress may be lost.")
                                        print(f"  ")
                                        print(f"  RECOVERY OPTIONS:")
                                        print(f"    1. Check for a backup: {state_file}.backup_*")
                                        print(f"    2. Use merge_partial_ComfyUI_batches.py to recover from PNGs")
                                        print(f"    3. Delete the state file and start over (loses progress)")
                                        print(f"  ")
                                        print(f"  Temp file preserved at: {temp_file}")
                                    else:
                                        print(f"  The existing state file appears VALID, but writes are failing.")
                                        print(f"  This may be due to: File Explorer preview pane, antivirus,")
                                        print(f"  search indexing, or another process holding a lock.")
                                        print(f"  ")
                                        print(f"  Temp file preserved at: {temp_file}")
                                    
                                    print(f"{'='*70}")
                                    # Stop the entire script
                                    os._exit(1)
                                
                                # Periodic backup every 25 successful writes
                                write_count += 1
                                if write_count >= 25:
                                    write_count = 0
                                    completed_count = sum(1 for c in state if c.get('status') == 'completed')
                                    backup_file = state_file + f'.backup_{completed_count}'
                                    with open(backup_file, 'wb') as f:
                                        pickle.dump(state, f)
                                    print(f"  Created backup: {backup_file}")
                                    
                        except (pickle.UnpicklingError, EOFError) as e:
                            print(f"State file corrupted - cannot read existing state: {e}")
                            print(f"Attempting to continue with in-memory state only...")
                            # Don't write - file is corrupt, but continue running?
                            # Better to exit:
                            print(f"CRITICAL: Exiting to prevent data loss.")
                            os._exit(1)
                        except Exception as e:
                            print(f"State writer error: {e}")
                        finally:
                            dist_state.release_lock()
                except queue.Empty:
                    continue

        # Start the writer thread
        state_writer = threading.Thread(target=state_writer_thread, daemon=True)
        state_writer.start()

        # Check if state file exists and is valid
        state_is_valid = False
        combinations = None
        
        if dist_state.state_file.exists() and dist_state.state_file.stat().st_size > 0:
            try:
                combinations = dist_state.load_state()
                if combinations and len(combinations) > 0:
                    state_is_valid = True
                    print(f"Loaded existing state with {len(combinations)} combinations")
                else:
                    print("State file exists but is empty or corrupt - will regenerate")
            except Exception as e:
                print(f"State file error: {e} - will regenerate")
        
        # Generate new state if needed (applies all ordering features)
        if not state_is_valid or not combinations:
            print("Generating new render queue...")
            
            # Step 1: Generate all possible combinations
            combinations = self.generate_combination_index(
                superprompts, metaprompts,
                superprompt_iterations, metaprompt_iterations
            )
            print(f"Generated {len(combinations)} total combinations")
            
            # Step 2: Apply unique-untried-first prioritization (if requested)
            # Note: For a fresh state, all combos are never-rendered with untouched prompts
            # This means the priority order is just the original order, but we preserve
            # the logic for when state files have existing completed renders
            if unique_untried_first:
                # For existing state files, we need to load completed status
                # For fresh state, all combos are equally "untried"
                if state_is_valid:
                    # Build sets of touched prompts from completed renders
                    touched_superprompts = {c['superprompt_idx'] for c in combinations if c.get('completed', False)}
                    touched_metaprompts = {c['metaprompt_idx'] for c in combinations if c.get('completed', False) and c['metaprompt_idx'] >= 0}
                    
                    def is_untouched_prompts(combo):
                        sp_touched = combo['superprompt_idx'] in touched_superprompts
                        mp_touched = combo['metaprompt_idx'] in touched_metaprompts if combo['metaprompt_idx'] >= 0 else False
                        return not (sp_touched or mp_touched)
                    
                    # Split pending combos by render history and prompt touch status
                    never_rendered = [c for c in combinations if not c.get('completed', False)]
                    already_rendered = [c for c in combinations if c.get('completed', False)]
                    
                    never_untouched = [c for c in never_rendered if is_untouched_prompts(c)]
                    never_touched = [c for c in never_rendered if not is_untouched_prompts(c)]
                    already_untouched = [c for c in already_rendered if is_untouched_prompts(c)]
                    already_touched = [c for c in already_rendered if not is_untouched_prompts(c)]
                    
                    # Combine in priority order
                    combinations = never_untouched + never_touched + already_untouched + already_touched
                    
                    print(f"Unique-untried-first mode: Enabled")
                    print(f"  Never-rendered + untouched prompts: {len(never_untouched)}")
                    print(f"  Never-rendered + touched prompts: {len(never_touched)}")
                    print(f"  Already-rendered + untouched prompts: {len(already_untouched)}")
                    print(f"  Already-rendered + touched prompts: {len(already_touched)}")
                else:
                    print(f"Unique-untried-first mode: Enabled (fresh state - all combos untried)")
            
            # Step 3: Apply sampling (take every Nth item)
            if sample_rate and 0 < sample_rate < 1:
                sample_step = int(1.0 / sample_rate)
                original_count = len(combinations)
                sampled_indices = set(range(0, original_count, sample_step))
                combinations = [combinations[i] for i in sorted(sampled_indices)]
                print(f"Sampling mode: {sample_rate*100:.1f}% of combinations ({len(combinations)} of {original_count} items)")
            
            # Step 4: Apply shuffle (randomize order)
            if shuffle:
                random.shuffle(combinations)
                print(f"Shuffle mode: Render order randomized")
            
            # Step 5: Apply resume filter (skip indices before start_from)
            if start_from is not None and start_from > 0:
                # Note: start_from refers to original indices before shuffling/sampling
                # This is a best-effort mapping
                combinations = [c for c in combinations if c.get('original_index', c['index']) >= start_from]
                print(f"Resume mode: Starting from original index {start_from}, {len(combinations)} combinations remain")
            
            # Step 6: Re-number all indices sequentially
            for idx, combo in enumerate(combinations):
                combo['index'] = idx
                combo['status'] = 'pending'
                combo['worker_id'] = None
                combo['claimed_at'] = None
                combo['last_update'] = None
                # Preserve completed status if it exists (for resume scenarios)
                if 'completed' in combo:
                    if combo['completed']:
                        combo['status'] = 'completed'
                    del combo['completed']
            
            # Save the newly generated state file
            with open(state_file, 'wb') as f:
                pickle.dump(combinations, f)
            print(f"Saved {len(combinations)} combinations to state file")
        
        # Verify we have combinations to render
        if not combinations:
            print("Error: No combinations to render")
            sys.exit(1)
        
        # Count pending renders
        pending_count = sum(1 for c in combinations if c.get('status') == 'pending')
        completed_count = sum(1 for c in combinations if c.get('status') == 'completed')
        
        print(f"\n{'='*70}")
        print(f"Starting {len(multi_host_urls)} independent render threads")
        print(f"  Total combinations: {len(combinations)}")
        print(f"  Already completed: {completed_count}")
        print(f"  Pending renders: {pending_count}")
        print(f"  Each host runs its own loop: claim -> render -> pause -> repeat")
        print(f"{'='*70}\n")
        
        # Worker function for a single dedicated host
        def host_worker(host_url, worker_id):
            """Independent worker thread for one host"""
            successful = 0
            failed = 0
            
            print(f"\n[Worker {worker_id}] Started for {host_url}")
            
            while True:
                # Claim a pending render from the shared state
                combo = dist_state.claim_next_pending(
                    heartbeat_interval, 
                    shuffle=shuffle, 
                    unique_untried_first=unique_untried_first
                )
                if not combo:
                    # Check if any renders are still pending or in progress
                    try:
                        with open(state_file, 'rb') as f:
                            state = pickle.load(f)
                        any_pending = any(c.get('status') == 'pending' for c in state)
                        any_rendering = any(c.get('status') == 'rendering' for c in state)
                        
                        if not any_pending and not any_rendering:
                            print(f"[Worker {worker_id}] No more renders - shutting down")
                            break
                        elif any_rendering:
                            print(f"[Worker {worker_id}] Waiting for other workers... ({sum(1 for c in state if c.get('status') == 'rendering')} in progress)")
                            time.sleep(30)
                            continue
                        else:
                            print(f"[Worker {worker_id}] No pending renders found")
                            break
                    except Exception as e:
                        print(f"[Worker {worker_id}] Error checking state: {e}")
                        time.sleep(30)
                        continue
                
                # Get global progress statistics before starting the render
                try:
                    with open(state_file, 'rb') as f:
                        state = pickle.load(f)
                    global_completed = sum(1 for c in state if c.get('status') == 'completed')
                    global_pending = sum(1 for c in state if c.get('status') == 'pending')
                    global_total = len(state)
                    global_rendering = sum(1 for c in state if c.get('status') == 'rendering')
                    
                    print(f"\n[Worker {worker_id}] --- Render {combo['index']} --- [{global_completed}/{global_total} completed, {global_pending} pending, {global_rendering} rendering]")
                except Exception as e:
                    print(f"\n[Worker {worker_id}] --- Render {combo['index']} --- (progress unavailable: {e})")
                
                print(f"[Worker {worker_id}] Superprompt [{combo['superprompt_idx']}]: {combo['superprompt'][:60]}...")
                if combo.get('metaprompt'):
                    print(f"[Worker {worker_id}] Metaprompt: {combo['metaprompt'][:60]}")
                
                # Load a fresh copy of the workflow for this render
                workflow = self.load_workflow(workflow_path)
                
                # Set up output directory structure
                if combo['metaprompt_idx'] >= 0:
                    output_subdir = str(Path(f"sp{combo['superprompt_idx']:03d}") / f"mp{combo['metaprompt_idx']:03d}")
                else:
                    output_subdir = str(Path(f"sp{combo['superprompt_idx']:03d}") / "no_meta")
                
                # Generate the final prompt by substituting metaprompt into template
                final_prompt = self.substitute_metaprompt(combo['superprompt'], combo.get('metaprompt', ''))
                random_seed = random.randint(1, 2**32 - 1)
                
                # Create a meaningful filename prefix from the prompt content
                safe_sp = self.sanitize_for_filename(combo['superprompt'], 20)
                if combo.get('metaprompt'):
                    safe_mp = self.sanitize_for_filename(combo['metaprompt'], 20)
                    filename_prefix = f"{safe_sp}__{safe_mp}__seed{random_seed}"
                else:
                    filename_prefix = f"{safe_sp}__seed{random_seed}"
                
                # Update the workflow with our render settings
                self.update_prompt_in_workflow(workflow, final_prompt, is_positive=True)
                self.update_seed_in_workflow(workflow, random_seed)
                self.update_output_node(workflow, output_subdir, filename_prefix)
                
                # Send to THIS dedicated host (no load balancing between hosts)
                print(f"[Worker {worker_id}] Sending to {host_url}")
                success = self.send_to_comfyui(workflow, render_timeout, host_url)
                
                # Update state based on result using the queue
                if success:
                    successful += 1
                    state_update_queue.put((combo['index'], 'completed', {
                        'seed': random_seed,
                        'timestamp': datetime.now().isoformat(),
                        'output_path': str(self.output_base_dir / output_subdir),
                        'worker_host': host_url
                    }))
                    print(f"[Worker {worker_id}] Render {combo['index']} COMPLETED (worker stats - successful: {successful}, failed: {failed})")
                else:
                    failed += 1
                    state_update_queue.put((combo['index'], 'pending', {
                        'seed': random_seed,
                        'timestamp': datetime.now().isoformat(),
                        'output_path': str(self.output_base_dir / output_subdir),
                        'worker_host': host_url
                    }))
                    print(f"[Worker {worker_id}] Render {combo['index']} FAILED (worker stats - successful: {successful}, failed: {failed})")
                
                # Pause AFTER each render on THIS host for GPU cooldown
                if pause_seconds > 0:
                    print(f"[Worker {worker_id}] Pausing {pause_seconds}s for GPU cooldown...")
                    time.sleep(pause_seconds)
            
            print(f"\n[Worker {worker_id}] Shutdown - Successful: {successful}, Failed: {failed}")
            return successful, failed

        # Single host vs multi-host handling
        if len(multi_host_urls) == 1:
            # Single host mode - run directly to capture accurate statistics
            print(f"Running in single-host mode (1 host)")
            successful, failed = host_worker(multi_host_urls[0], 0)
            total_successful, total_failed = successful, failed
            
            # Load final state for overall statistics
            try:
                with open(state_file, 'rb') as f:
                    final_state = pickle.load(f)
                final_completed = sum(1 for c in final_state if c.get('status') == 'completed')
                final_pending = sum(1 for c in final_state if c.get('status') == 'pending')
                final_rendering = sum(1 for c in final_state if c.get('status') == 'rendering')
                final_total = len(final_state)
                
                print(f"\n{'='*70}")
                print(f"SESSION COMPLETE")
                print(f"  This session - Successful: {total_successful}, Failed: {total_failed}")
                print(f"  ")
                print(f"  Current state from pickle file:")
                print(f"    Total combinations: {final_total}")
                print(f"    Completed: {final_completed}")
                print(f"    Pending: {final_pending}")
                print(f"    In progress: {final_rendering}")
                if final_pending > 0 or final_rendering > 0:
                    print(f"  ")
                    print(f"  NOTE: Some renders remain. Run again with --resume to continue.")
                print(f"{'='*70}")
            except Exception as e:
                print(f"\nCould not read final state: {e}")
        else:
            # Multi-host mode - use threads, stats not reliable
            threads = []
            
            # Launch all worker threads directly
            for i, host_url in enumerate(multi_host_urls):
                thread = threading.Thread(target=host_worker, args=(host_url, i))
                thread.daemon = True
                thread.start()
                threads.append(thread)
            
            # Wait for all threads to complete
            try:
                for thread in threads:
                    thread.join()
            except KeyboardInterrupt:
                print("\n\nInterrupted by user - waiting for threads to finish current renders...")
                time.sleep(5)
            
            # Load final state from pickle file (only reliable source in multi-host)
            try:
                with open(state_file, 'rb') as f:
                    final_state = pickle.load(f)
                final_completed = sum(1 for c in final_state if c.get('status') == 'completed')
                final_pending = sum(1 for c in final_state if c.get('status') == 'pending')
                final_rendering = sum(1 for c in final_state if c.get('status') == 'rendering')
                final_total = len(final_state)
                
                print(f"\n{'='*70}")
                print(f"SESSION INTERRUPTED OR COMPLETED")
                print(f"  NOTE: Per-session statistics are not available in multi-host mode")
                print(f"        due to async worker threads and interrupt handling.")
                print(f"  ")
                print(f"  Current state from pickle file:")
                print(f"    Total combinations: {final_total}")
                print(f"    Completed: {final_completed}")
                print(f"    Pending: {final_pending}")
                print(f"    In progress: {final_rendering}")
                if final_pending > 0 or final_rendering > 0:
                    print(f"  ")
                    print(f"  NOTE: Some renders remain. Run again with --resume to continue.")
                print(f"{'='*70}")
            except Exception as e:
                print(f"\nCould not read final state: {e}")
        
        # === SHUTDOWN STATE WRITER (after printing stats, before exiting) ===
        try:
            state_update_queue.put(None)  # Poison pill to stop writer
            stop_state_writer.set()
            state_writer.join(timeout=5)
        except NameError:
            pass  # state_writer was never created (error before initialization)

def main():
    parser = argparse.ArgumentParser(description='ComfyUI Batch Render - Multi-Host & Distributed Support')
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
                       help='ComfyUI server URL(s). For multiple hosts, use comma-separated: '
                            'http://host1:8188,http://host2:8188 (default: http://127.0.0.1:8188)')
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
    parser.add_argument('--heartbeat-interval', 
                       type=int, 
                       default=30,
                       help='Heartbeat interval for distributed mode (seconds, default: 30)')
    
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
    
    # Parse hosts - always split by comma (works for 1 or many)
    hosts = [url.strip() for url in args.url.split(',')]
    
    print(f"\n{'='*70}")
    if len(hosts) == 1:
        print(f"COMFYUI BATCH RENDERER")
    else:
        print(f"DISTRIBUTED BATCH RENDERER ({len(hosts)} hosts)")
    print(f"  Hosts: {len(hosts)}")
    for i, host in enumerate(hosts):
        print(f"    {i+1}. {host}")
    print(f"{'='*70}\n")
    
    renderer = ComfyUIBatchRenderer(server_url=hosts[0], output_base_dir=args.outputdir)
    renderer.run_batch_distributed(
        workflow_path=args.workflowfilename,
        superprompt_iterations=args.superpromptiterations,
        metaprompt_iterations=args.metapromptiterations,
        pause_seconds=args.pause,
        render_timeout=args.timeout,
        superprompt_file=args.superprompts,
        metaprompt_file=args.metaprompts,
        state_file=args.state_file,
        heartbeat_interval=args.heartbeat_interval,
        multi_host_urls=hosts,
        shuffle=args.shuffle,
        unique_untried_first=args.unique_untried_first,
        sample_rate=args.sample,
        start_from=args.resume
    )

if __name__ == "__main__":
    main()