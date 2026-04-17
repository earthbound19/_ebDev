#!/usr/bin/env python3
"""
SCRIPT: merge_partial_ComfyUI_batches.py
VERSION: 1.6.0

DESCRIPTION:
    Merge partially completed batch runs into a single state file, to allow
    combining renders (and render state) of different runs of the same super- and
    meta- prompts + workflow + -s + -m switches, from comfyUIbatchRunner.py
    
    If you run comfyUIbatchRunner.py with --shuffle, or when interrupting/resuming
    runs at different times and to different target render directories, you'll end up
    with partial render sets (part of total possible images) for the same configuration.
    The render state (pickle) file of one or both, and / or the image sets, could help,
    together, form more of the render space (total renders) of a batch, IF you
    can merge the rendered images information into the state (pickle) file. (And manually
    copy the subfolder structures and files into the same directory.) This script allows
    you to do that: merge them into one master state file. 
    
    This merges render information into a target pickle file by processing either
    or both of these sources:
        --source-state-file     : Another state pickle file from a partial run
        --source-curated-dir    : Directory containing kept PNGs from a partial run
    
    It updates the target state file (pickle file) by marking matching renders as
    'completed', creating a union of all completed renders from all sources.

DEPENDENCIES:
    Python 3.6 or higher
    Pillow (PIL) library (pip install Pillow)

USAGE:
    # Merge from another state file only
    python merge_partial_ComfyUI_batches.py \\
        --source-state-file ./old_run/state.pkl \\
        --merge-to-state-file ./current_run/state.pkl
    
    # Merge from curated PNGs only
    python merge_partial_ComfyUI_batches.py \\
        --source-curated-dir ./kept_images \\
        --merge-to-state-file ./state.pkl \\
        --original-super superprompts.txt --original-meta metaprompts.txt
    
    # Merge from both sources
    python merge_partial_ComfyUI_batches.py \\
        --source-state-file ./run_a/state.pkl \\
        --source-curated-dir ./run_a/kept \\
        --merge-to-state-file ./master_state.pkl

REQUIRED ARGUMENTS:
    --merge-to-state-file FILE    State file to update (must exist)
    
SOURCE ARGUMENTS (at least one required):
    --source-state-file FILE      A state file to merge completions from
    --source-curated-dir PATH     Directory with PNGs to scan for completions

OPTIONAL ARGUMENTS:
    --original-super FILE         Superprompts file (default: superprompts.txt)
                                  Required when using --source-curated-dir
    --original-meta FILE          Metaprompts file (default: metaprompts.txt)
                                  Required when using --source-curated-dir
    --dry-run                     Show what would be updated without modifying
    --force                       Skip the confirmation prompt

CRITICAL WARNINGS:
    DO NOT run this script while comfyUIbatchRunner.py is running on the target
    state file! Any resulting concurrent access if you do that could corrupt the state file.
    
    The source and target runs MUST have used IDENTICAL:
        - superprompts.txt (same content, same line order)
        - metaprompts.txt (same content, same line order)
        - -s (superpromptiterations) value
        - -m (metapromptiterations) value
    
    For state-file-to-state-file merging, the script validates that both state files
    have the same length (same number of combinations). If they differ, it aborts.
    
    This script does NOT implement file locking. You are responsible for
    ensuring no batch runner is accessing the target state file during state file
    merge via this script.
    
    If you provide mismatched prompt files, PNGs will fail to match and will
    be skipped with warning messages. The state file will not be corrupted.

NOTES:
    MATCHING LOGIC:
        For state file sources: Matches by (superprompt_idx, metaprompt_idx,
                                 superprompt_repetition, metaprompt_repetition)
        For PNG sources: Extracts prompt via reverse substitution (matching by text
                        content, not by index), then matches by (superprompt_idx,
                        metaprompt_idx). If multiple repetitions exist for that pair,
                        the first pending repetition is chosen. If none are pending,
                        the PNG is skipped and counted.
    
    SAFETY:
        The script never downgrades 'completed' to 'pending' or any other status.
        It only updates non-completed render statuses ('pending', 'rendering' or
        'failed') to 'completed' - IF it finds evidence they completed. Otherwise
        it leaves render states as-is in the state file.
        Uses atomic write (temp file + rename) to prevent corruption
    
    STATISTICS:
        Reports how many new completions were added from each source (source
        curated dir or state file)
        Shows before/after counts for target state file

EXAMPLES:
    # Merge a partial run into a master state
    python merge_partial_ComfyUI_batches.py \\
        --source-state-file ./partial_run/state.pkl \\
        --merge-to-state-file ./master_state.pkl
    
    # Recover from PNGs after state file corruption (dry run first)
    python merge_partial_ComfyUI_batches.py \\
        --source-curated-dir ./renders \\
        --merge-to-state-file ./recovered_state.pkl \\
        --original-super superprompts.txt --original-meta metaprompts.txt \\
        --dry-run

TO DO:
Option to move files marked completed (for cases where there is a mix of matches or not,
or any time, for convenience).
"""

import argparse
import json
import pickle
import sys
import os
import shutil
from pathlib import Path
from collections import defaultdict
from datetime import datetime
from PIL import Image

def extract_prompt_and_seed_from_png(png_path):
    """Extract positive prompt and seed from PNG metadata.
    
    Returns:
        tuple: (full_prompt, seed) or (None, None) if extraction fails
    """
    try:
        with Image.open(png_path) as img:
            metadata = img.text
            if 'prompt' not in metadata:
                return None, None
            
            workflow = json.loads(metadata['prompt'])
            
            # Find positive prompt
            prompt_text = None
            for node_id, node_data in workflow.items():
                if node_data.get('class_type') == 'CLIPTextEncode':
                    title = node_data.get('_meta', {}).get('title', '')
                    if 'Prompt Positive' in title:
                        prompt_text = node_data.get('inputs', {}).get('text', '')
                        break
            
            if prompt_text is None:
                # Fallback: look for any CLIPTextEncode with 'positive' in title
                for node_id, node_data in workflow.items():
                    if node_data.get('class_type') == 'CLIPTextEncode':
                        title = node_data.get('_meta', {}).get('title', '').lower()
                        if 'positive' in title:
                            prompt_text = node_data.get('inputs', {}).get('text', '')
                            break
            
            # Find seed
            seed = None
            for node_id, node_data in workflow.items():
                if node_data.get('class_type') == 'KSampler':
                    seed = node_data.get('inputs', {}).get('seed')
                    break
            
            return prompt_text, seed
            
    except Exception as e:
        print(f"  Warning: Could not read {png_path.name}: {e}")
        return None, None

def extract_super_and_metaprompt(full_prompt, superprompts, metaprompts):
    """Reverse-engineer which superprompt template and metaprompt produced this full prompt.
    
    Args:
        full_prompt: The complete prompt string
        superprompts: List of superprompt templates (may contain '{}')
        metaprompts: List of metaprompt values (may be empty)
    
    Returns:
        tuple: (superprompt_idx, metaprompt_idx) or (None, None)
    """
    # Handle empty metaprompts case (treat as single empty string)
    effective_metaprompts = metaprompts if metaprompts else [""]
    
    for sp_idx, sp in enumerate(superprompts):
        if '{}' in sp:
            # Try to extract metaprompt by splitting on placeholder
            parts = sp.split('{}')
            if len(parts) == 2:
                # Check if full_prompt starts with parts[0] and ends with parts[1]
                if full_prompt.startswith(parts[0]) and full_prompt.endswith(parts[1]):
                    mp_candidate = full_prompt[len(parts[0]):-len(parts[1])]
                    
                    # Match against metaprompts list
                    if mp_candidate in effective_metaprompts:
                        mp_idx = metaprompts.index(mp_candidate) if metaprompts else -1
                        return sp_idx, mp_idx
        else:
            # No placeholder - direct match
            if full_prompt == sp:
                return sp_idx, -1 if not metaprompts else 0  # -1 indicates no metaprompt
    
    return None, None

def load_state_file(state_path):
    """Load state pickle file."""
    try:
        with open(state_path, 'rb') as f:
            state = pickle.load(f)
        
        if not isinstance(state, list):
            print(f"Error: {state_path} does not contain a valid state list")
            return None
        
        if len(state) == 0:
            print(f"Error: {state_path} is empty")
            return None
        
        return state
    except Exception as e:
        print(f"Error loading {state_path}: {e}")
        return None

def save_state_file(state, state_path):
    """Save state file atomically using temp file + rename."""
    temp_file = state_path.with_suffix('.tmp')
    
    try:
        # Write to temp file
        with open(temp_file, 'wb') as f:
            pickle.dump(state, f)
            f.flush()
            os.fsync(f.fileno())
        
        # Atomic replace (works on Unix, Windows with replace())
        try:
            temp_file.replace(state_path)
        except (OSError, PermissionError):
            # Fallback for older Python or permission issues
            shutil.copy2(temp_file, state_path)
            temp_file.unlink()
        
        return True
    except Exception as e:
        print(f"Error saving state file: {e}")
        if temp_file.exists():
            temp_file.unlink()
        return False

def build_state_lookup_by_full_key(state):
    """Build lookup dictionary for state entries by (sp_idx, mp_idx, s_rep, m_rep).
    
    This is the actual unique key for each combination in the state file.
    
    Returns:
        dict: {(superprompt_idx, metaprompt_idx, superprompt_repetition, metaprompt_repetition): state_index}
    """
    lookup = {}
    for idx, combo in enumerate(state):
        key = (
            combo['superprompt_idx'],
            combo.get('metaprompt_idx', -1),
            combo['superprompt_repetition'],
            combo['metaprompt_repetition']
        )
        lookup[key] = idx
    return lookup

def build_state_lookup_by_sp_mp_only(state):
    """Build lookup for state entries by (sp_idx, mp_idx) only.
    
    Returns list of indices for each (sp_idx, mp_idx) pair.
    
    Returns:
        dict: {(superprompt_idx, metaprompt_idx): [state_index1, state_index2, ...]}
    """
    lookup = defaultdict(list)
    for idx, combo in enumerate(state):
        key = (
            combo['superprompt_idx'],
            combo.get('metaprompt_idx', -1)
        )
        lookup[key].append(idx)
    return lookup

def validate_state_lengths_match(target_state, source_state):
    """Validate that target and source state files have the same length.
    
    Returns:
        bool: True if lengths match, False otherwise
    """
    if len(target_state) != len(source_state):
        print(f"\n{'='*70}")
        print(f"VALIDATION ERROR: State file size mismatch")
        print(f"{'='*70}")
        print(f"  Target state has {len(target_state)} combinations")
        print(f"  Source state has {len(source_state)} combinations")
        print(f"\n  This usually means:")
        print(f"    - The runs used different -s or -m values")
        print(f"    - The prompt files have different lengths")
        print(f"\n  State-file-to-state-file merging requires identical")
        print(f"  combination counts. Aborting to prevent corruption.")
        print(f"{'='*70}")
        return False
    return True

def merge_from_state_file(source_state, target_lookup, target_state, dry_run=False):
    """Merge completed renders from source state file into target state.
    
    Matches by (sp_idx, mp_idx, s_rep, m_rep) - the actual unique key.
    
    Returns:
        tuple: (added_count, already_completed_count, not_found_count)
    """
    added = 0
    already_completed = 0
    not_found = 0
    
    for combo in source_state:
        # Only merge completed renders
        if combo.get('status') != 'completed' and not combo.get('completed', False):
            continue
        
        key = (
            combo['superprompt_idx'],
            combo.get('metaprompt_idx', -1),
            combo['superprompt_repetition'],
            combo['metaprompt_repetition']
        )
        
        # Find matching entry in target
        if key in target_lookup:
            target_idx = target_lookup[key]
            
            # Check if already completed
            if target_state[target_idx].get('status') == 'completed':
                already_completed += 1
            else:
                if not dry_run:
                    target_state[target_idx]['status'] = 'completed'
                    target_state[target_idx]['worker_id'] = 'merged_from_state'
                    target_state[target_idx]['last_update'] = datetime.now().isoformat()
                    
                    # Preserve the source's seed if it exists, otherwise keep target's
                    if combo.get('seed') is not None:
                        target_state[target_idx]['seed'] = combo['seed']
                added += 1
                
                if not dry_run:
                    print(f"  ✓ Marked as completed: sp{combo['superprompt_idx']}, "
                          f"mp{combo.get('metaprompt_idx', -1)}, "
                          f"s_rep={combo['superprompt_repetition']}, "
                          f"m_rep={combo['metaprompt_repetition']}")
        else:
            not_found += 1
    
    if not_found > 0:
        print(f"  Warning: {not_found} completed renders from source state not found in target")
    
    return added, already_completed, not_found

def merge_from_curated_dir(curated_dir, superprompts, metaprompts, target_lookup_by_sp_mp, 
                           target_state, dry_run=False):
    """Merge completed renders from PNG files in curated directory.
    
    Matches by (sp_idx, mp_idx) and seed. First checks if the exact seed already exists
    as completed. If not, finds the first pending repetition for that (sp, mp) pair.
    
    Returns:
        tuple: (added_count, already_completed_count, unmatched_count, 
                no_metadata_count, no_pending_slots_count)
    """
    curated_path = Path(curated_dir)
    if not curated_path.exists():
        print(f"Error: Curated directory not found: {curated_dir}")
        return 0, 0, 0, 0, 0
    
    # Find all PNGs recursively
    png_files = list(curated_path.rglob("*.png"))
    print(f"  Found {len(png_files)} PNGs in {curated_dir}")
    
    added = 0
    already_completed = 0
    unmatched = 0
    no_metadata = 0
    no_pending_slots = 0
    
    for png_path in png_files:
        # Extract metadata
        full_prompt, seed = extract_prompt_and_seed_from_png(png_path)
        
        if full_prompt is None or seed is None:
            no_metadata += 1
            continue
        
        # Find which superprompt/metaprompt this corresponds to
        sp_idx, mp_idx = extract_super_and_metaprompt(full_prompt, superprompts, metaprompts)
        
        if sp_idx is None:
            unmatched += 1
            if not dry_run:
                print(f"  Warning: Could not match prompt from {png_path.name}")
            continue
        
        # Find all target indices for this (sp, mp) pair
        key = (sp_idx, mp_idx)
        if key not in target_lookup_by_sp_mp:
            unmatched += 1
            if not dry_run:
                print(f"  Warning: No state entries for (sp{sp_idx}, mp{mp_idx}) from {png_path.name}")
            continue
        
        target_indices = target_lookup_by_sp_mp[key]
        
        # First, check if this exact seed already exists as completed
        seed_found_completed = False
        for target_idx in target_indices:
            if (target_state[target_idx].get('status') == 'completed' and 
                target_state[target_idx].get('seed') == seed):
                seed_found_completed = True
                already_completed += 1
                if not dry_run:
                    s_rep = target_state[target_idx]['superprompt_repetition']
                    m_rep = target_state[target_idx]['metaprompt_repetition']
                    print(f"  Already completed (seed match): sp{sp_idx}, mp{mp_idx}, "
                          f"s_rep={s_rep}, m_rep={m_rep}, seed={seed}")
                break
        
        if seed_found_completed:
            continue
        
        # Seed not found - look for a pending entry among the repetitions
        found_pending = False
        for target_idx in target_indices:
            if target_state[target_idx].get('status') != 'completed':
                # Found a pending entry - mark it completed
                if not dry_run:
                    target_state[target_idx]['status'] = 'completed'
                    target_state[target_idx]['worker_id'] = 'merged_from_curated'
                    target_state[target_idx]['last_update'] = datetime.now().isoformat()
                    target_state[target_idx]['seed'] = seed  # Store the seed from PNG
                added += 1
                found_pending = True
                
                if not dry_run:
                    s_rep = target_state[target_idx]['superprompt_repetition']
                    m_rep = target_state[target_idx]['metaprompt_repetition']
                    print(f"  Marked as completed: sp{sp_idx}, mp{mp_idx}, "
                          f"s_rep={s_rep}, m_rep={m_rep}, seed={seed}")
                break
        
        if not found_pending:
            # All repetitions for this (sp, mp) are already completed
            no_pending_slots += 1
            if not dry_run:
                print(f"  Warning: No pending slots for (sp{sp_idx}, mp{mp_idx}) from {png_path.name}")
    
    if no_metadata > 0:
        print(f"  Warning: {no_metadata} PNGs had no extractable prompt/seed metadata")
    if unmatched > 0:
        print(f"  Warning: {unmatched} PNGs could not be matched to state entries")
    if no_pending_slots > 0:
        print(f"  Warning: {no_pending_slots} PNGs matched (sp,mp) but had no pending slots")
        print(f"           (all repetitions of that prompt pair are already completed)")
    
    return added, already_completed, unmatched, no_metadata, no_pending_slots

def main():
    parser = argparse.ArgumentParser(
        description='Merge partially completed ComfyUI batch runs into a single state file',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
CRITICAL WARNINGS:
    DO NOT run this script while comfyUIbatchRunner.py is running on the target
    state file! Any resulting concurrent access if you do that could corrupt the state file.
    
    The source and target runs MUST have used IDENTICAL:
        - superprompts.txt (same content, same line order)
        - metaprompts.txt (same content, same line order)
        - -s (superpromptiterations) value
        - -m (metapromptiterations) value
    
    For state-file-to-state-file merging, the script validates that both state files
    have the same length (same number of combinations). If they differ, it aborts.
    
    This script does NOT implement file locking. You are responsible for
    ensuring no batch runner is accessing the target state file during state file
    merge via this script.
    
    If you provide mismatched prompt files, PNGs will fail to match and will
    be skipped with warning messages. The state file will not be corrupted.
"""
    )
    
    parser.add_argument('--merge-to-state-file', required=True,
                       help='State file to update (must exist)')
    parser.add_argument('--source-state-file', default=None,
                       help='A state file to merge completions from')
    parser.add_argument('--source-curated-dir', default=None,
                       help='Directory with PNGs to scan for completions')
    parser.add_argument('--original-super', default='superprompts.txt',
                       help='Superprompts file (default: superprompts.txt)')
    parser.add_argument('--original-meta', default='metaprompts.txt',
                       help='Metaprompts file (default: metaprompts.txt)')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what would be updated without modifying')
    parser.add_argument('--force', action='store_true',
                       help='Skip the confirmation prompt')
    
    args = parser.parse_args()
    
    # Validate at least one source
    if not args.source_state_file and not args.source_curated_dir:
        print("Error: At least one of --source-state-file or --source-curated-dir is required")
        sys.exit(1)
    
    # Load target state file
    target_path = Path(args.merge_to_state_file)
    if not target_path.exists():
        print(f"Error: Target state file not found: {target_path}")
        sys.exit(1)
    
    print(f"\n{'='*70}")
    print(f"Merging partial batch runs into: {target_path}")
    print(f"{'='*70}\n")
    
    target_state = load_state_file(target_path)
    if target_state is None:
        sys.exit(1)
    
    # Load prompt files (required for curated dir source)
    superprompts = None
    metaprompts = None
    
    if args.source_curated_dir:
        try:
            with open(args.original_super, 'r', encoding='utf-8') as f:
                superprompts = [line.strip() for line in f if line.strip()]
            print(f"Loaded {len(superprompts)} superprompts from: {args.original_super}")
        except FileNotFoundError:
            print(f"Error: Superprompts file not found: {args.original_super}")
            sys.exit(1)
        
        try:
            with open(args.original_meta, 'r', encoding='utf-8') as f:
                metaprompts = [line.strip() for line in f if line.strip()]
            print(f"Loaded {len(metaprompts)} metaprompts from: {args.original_meta}")
        except FileNotFoundError:
            print(f"Warning: Metaprompts file not found: {args.original_meta}")
            metaprompts = []
    
    # Build lookups for target state
    target_lookup_by_full_key = build_state_lookup_by_full_key(target_state)
    target_lookup_by_sp_mp = build_state_lookup_by_sp_mp_only(target_state)
    
    # Count current completions
    current_completed = sum(1 for c in target_state if c.get('status') == 'completed')
    total_combinations = len(target_state)
    
    print(f"\nTarget state before merge:")
    print(f"  Total combinations: {total_combinations}")
    print(f"  Completed: {current_completed}")
    print(f"  Pending: {total_combinations - current_completed}\n")
    
    # Merge from state file (if provided)
    total_added = 0
    total_already = 0
    total_not_found = 0
    
    if args.source_state_file:
        print(f"Processing source state file: {args.source_state_file}")
        source_state = load_state_file(args.source_state_file)
        if source_state is not None:
            # Validate lengths match before merging
            if not validate_state_lengths_match(target_state, source_state):
                sys.exit(1)
            
            added, already, not_found = merge_from_state_file(
                source_state, target_lookup_by_full_key, target_state, args.dry_run
            )
            total_added += added
            total_already += already
            total_not_found += not_found
            print(f"  Added: {added} new completions, {already} already completed, {not_found} not found\n")
        else:
            print(f"  Skipping {args.source_state_file}\n")
    
    # Merge from curated directory (if provided)
    curated_added = 0
    curated_already = 0
    curated_unmatched = 0
    curated_no_metadata = 0
    curated_no_pending = 0
    
    if args.source_curated_dir:
        print(f"Processing curated directory: {args.source_curated_dir}")
        added, already, unmatched, no_metadata, no_pending = merge_from_curated_dir(
            args.source_curated_dir, superprompts, metaprompts, 
            target_lookup_by_sp_mp, target_state, args.dry_run
        )
        curated_added = added
        curated_already = already
        curated_unmatched = unmatched
        curated_no_metadata = no_metadata
        curated_no_pending = no_pending
        total_added += added
        total_already += already
        print(f"  Added: {added} new completions, {already} already completed\n")
    
    # Show summary
    new_completed = current_completed + total_added
    print(f"{'='*70}")
    print(f"MERGE SUMMARY")
    print(f"  New completions added: {total_added}")
    print(f"  Already completed in target: {total_already}")
    if total_not_found > 0:
        print(f"  Not found in target (state file): {total_not_found}")
    if curated_no_metadata > 0:
        print(f"  PNGs with no metadata: {curated_no_metadata}")
    if curated_unmatched > 0:
        print(f"  PNGs that couldn't be matched: {curated_unmatched}")
    if curated_no_pending > 0:
        print(f"  PNGs with no pending slots: {curated_no_pending}")
    print(f"  ")
    print(f"  Target state after merge:")
    print(f"    Total combinations: {total_combinations}")
    print(f"    Completed: {new_completed}")
    print(f"    Pending: {total_combinations - new_completed}")
    print(f"{'='*70}")
    
    if total_added > 0 and not args.dry_run:
        print(f"\nREMINDER: The state file will be updated, but the actual image files")
        print(f"          from your source runs will still need to be copied manually")
        print(f"          into your target output directory to complete the merge.")
    
    if total_added == 0:
        print("\nNo new completions to add. Nothing to save.")
        sys.exit(0)
    
    # Confirm and save
    if not args.dry_run:
        if not args.force:
            print(f"\nWARNING: You are about to update {target_path}")
            print(f"This will add {total_added} new completion records.")
            print(f"Backup {target_path} before proceeding.")
            print(f"Merge cannot be undone.")
            response = input("Proceed? (y/N): ").strip().lower()
            if response != 'y':
                print("Aborted.")
                sys.exit(0)
        
        if save_state_file(target_state, target_path):
            print(f"\n✓ Successfully updated {target_path}")
        else:
            print(f"\n✗ Failed to save {target_path}")
            sys.exit(1)
    else:
        print(f"\nDRY RUN: No changes were saved.")
        print(f"To actually apply changes, run without --dry-run")

if __name__ == "__main__":
    main()