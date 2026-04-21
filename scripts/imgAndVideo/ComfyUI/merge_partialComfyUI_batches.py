#!/usr/bin/env python3
"""
SCRIPT: merge_partial_ComfyUI_batches.py
VERSION: 1.10.15

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

    DISASTER RECOVERY:
        If your active state file becomes corrupted but you have a backup, you can
        copy a the most recent backup to the current pickle file name, and run
        this script to recover any missing update states via PNG renders evidence:
            cp backup.pkl active_state.pkl
            python merge_partial_ComfyUI_batches.py \\
                --source-curated-dir ./output_renders \\
                --merge-to-state-file ./active_state.pkl \\
                --original-super superprompts.txt --original-meta metaprompts.txt
        
        The script will scan your PNG files and mark any completed renders
        that occurred after the backup was created.

    This merges render information into a target pickle file by processing either
    or both of these sources:
        --source-state-file     : Another state pickle file from a partial run
        --source-curated-dir    : Directory containing kept PNGs from a partial run
    
    It updates the target state file (pickle file) by marking matching renders as
    'completed', creating a union of all completed renders from all sources.

    ORPHAN RECOVERY:
        Orphans are PNG files that exist in your curated directory but could not be
        matched to any entry in the state file. This can happen when:
            - Prompt files have changed since the images were generated
            - Images come from a different workflow or batch configuration
            - PNG metadata is corrupted or missing
            - Prompt matching fails?
        
        When orphans are detected, the script offers to move them to:
            {source_curated_dir}/_discards/_orphans/
        
        This keeps your curated directory clean while preserving orphans for:
            - Manual inspection to understand why they didn't match
            - Recovery if you later determine they should be merged
            - Comparison against updated prompt files in future runs
        
        Orphans are MOVED (not copied) to preserve disk space. The relative
        subdirectory structure is maintained within the _orphans sub-subfolder.
        
        To process orphans without merging state updates, run with:
            --source-curated-dir ./kept_images --dry-run
        (Then remove --dry-run to actually move them)

    ORGANIZE COMPLETED RENDERS:
        After merging, the script will interactively prompt to organize PNG files
        that are already marked as completed in the state file. This is useful for:
            - Consolidating renders from multiple partial runs into one organized directory
            - Reorganizing an existing render directory to match the standard structure
            - Recovering files that were manually moved or scattered
        
        It will:
        1. Scan the --source-curated-dir for PNG files (extracts prompt and seed from metadata)
        2. Match them against completed renders in the state file
        3. Move or copy them to a user-specified target directory using the proper folder structure:
           spXXX/mpYYY/ (or spXXX/no_meta/ for empty metaprompts)
        4. Preserve the filename structure (or optionally rename using seed information)

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
            parts = sp.split('{}')
            if len(parts) == 2:
                if full_prompt.startswith(parts[0]) and full_prompt.endswith(parts[1]):
                    # Fix: handle empty parts[1] correctly (avoid -0 slice bug)
                    if len(parts[1]) == 0:
                        mp_candidate = full_prompt[len(parts[0]):]
                    else:
                        mp_candidate = full_prompt[len(parts[0]):-len(parts[1])]
                    
                    if mp_candidate in effective_metaprompts:
                        mp_idx = metaprompts.index(mp_candidate) if metaprompts else -1
                        return sp_idx, mp_idx
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

def build_completed_lookup_by_sp_mp_seed(state):
    """Build lookup for completed entries by (sp_idx, mp_idx, seed).
    
    Returns:
        dict: {(superprompt_idx, metaprompt_idx, seed): state_index}
    """
    lookup = {}
    for idx, combo in enumerate(state):
        if combo.get('status') == 'completed' and combo.get('seed') is not None:
            key = (
                combo['superprompt_idx'],
                combo.get('metaprompt_idx', -1),
                combo['seed']
            )
            lookup[key] = idx
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
                    print(f"  Match found: sp{combo['superprompt_idx']}, "
                          f"mp{combo.get('metaprompt_idx', -1)}, "
                          f"s_rep={combo['superprompt_repetition']}, "
                          f"m_rep={combo['metaprompt_repetition']}")
                else:
                    print(f"  Would mark as completed: sp{combo['superprompt_idx']}, "
                          f"mp{combo.get('metaprompt_idx', -1)}, "
                          f"s_rep={combo['superprompt_repetition']}, "
                          f"m_rep={combo['metaprompt_repetition']}")
        else:
            not_found += 1
    
    if not_found > 0:
        print(f"  Warning: {not_found} completed renders from source state not found in target")
    
    return added, already_completed, not_found

def merge_from_curated_dir(curated_dir, superprompts, metaprompts, target_lookup_by_sp_mp, 
                           target_state, dry_run=False, matched_files=None, orphan_files=None):
    """Merge completed renders from PNG files in curated directory.
    
    Matches by (sp_idx, mp_idx) and seed. First checks if the exact seed already exists
    as completed. If not, finds the first pending repetition for that (sp, mp) pair.
    
    Tracks unmatched PNGs (orphans) separately for optional moving.
    
    Returns:
        tuple: (added_count, already_completed_count, unmatched_count, 
                no_metadata_count, no_pending_slots_count, matched_files_list, orphan_files_list)
    """
    if matched_files is None:
        matched_files = []
    if orphan_files is None:
        orphan_files = []
    
    curated_path = Path(curated_dir)
    if not curated_path.exists():
        print(f"Error: Curated directory not found: {curated_dir}")
        return 0, 0, 0, 0, 0, matched_files, orphan_files
    
    # Find all PNGs recursively
    png_files = [p for p in curated_path.rglob("*.png") if '_discards' not in p.parts]
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
            orphan_files.append(str(png_path))
            if not dry_run:
                print(f"  Orphan (could not match prompt): {png_path.name}")
            continue
        
        # Find all target indices for this (sp, mp) pair
        key = (sp_idx, mp_idx)
        if key not in target_lookup_by_sp_mp:
            unmatched += 1
            orphan_files.append(str(png_path))
            if not dry_run:
                print(f"  Orphan (no state entries): {png_path.name}")
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
                # Found a pending entry - would mark it completed
                if not dry_run:
                    target_state[target_idx]['status'] = 'completed'
                    target_state[target_idx]['worker_id'] = 'merged_from_curated'
                    target_state[target_idx]['last_update'] = datetime.now().isoformat()
                    target_state[target_idx]['seed'] = seed
                    print(f"  Match found: sp{sp_idx}, mp{mp_idx}, "
                          f"s_rep={target_state[target_idx]['superprompt_repetition']}, "
                          f"m_rep={target_state[target_idx]['metaprompt_repetition']}, seed={seed}")
                    matched_files.append(str(png_path))
                else:
                    s_rep = target_state[target_idx]['superprompt_repetition']
                    m_rep = target_state[target_idx]['metaprompt_repetition']
                    print(f"  Would mark as completed: sp{sp_idx}, mp{mp_idx}, "
                          f"s_rep={s_rep}, m_rep={m_rep}, seed={seed}")
                added += 1
                found_pending = True
                break
        
        if not found_pending:
            no_pending_slots += 1
            if not dry_run:
                print(f"  Warning: No pending slots for (sp{sp_idx}, mp{mp_idx}) from {png_path.name}")
    
    if no_metadata > 0:
        print(f"  Warning: {no_metadata} PNGs had no extractable prompt/seed metadata")
    if no_pending_slots > 0:
        print(f"  Warning: {no_pending_slots} PNGs matched (sp,mp) but had no pending slots")
        print(f"           (all repetitions of that prompt pair are already completed)")
    
    return added, already_completed, unmatched, no_metadata, no_pending_slots, matched_files, orphan_files

def organize_completed_renders(state, superprompts, metaprompts, source_dir, target_dir, 
                                copy_mode=False, rename_by_seed=False, dry_run=False):
    """Organize PNG files that are already marked as completed in the state file.
    
    Args:
        state: The target state list
        superprompts: List of superprompt templates
        metaprompts: List of metaprompt values
        source_dir: Source directory to scan for PNGs
        target_dir: Target directory to organize into
        copy_mode: If True, copy files; if False, move files
        rename_by_seed: If True, rename files to include seed; if False, keep original name
        dry_run: If True, only show what would be done
    
    Returns:
        tuple: (organized_count, failed_count, already_organized_count)
    """
    source_path = Path(source_dir)
    target_path = Path(target_dir)
    
    if not source_path.exists():
        print(f"Error: Source directory not found: {source_dir}")
        return 0, 0, 0
    
    # Create target directory if it doesn't exist
    if not dry_run:
        target_path.mkdir(parents=True, exist_ok=True)
    
    # Build lookup for completed entries by (sp_idx, mp_idx, seed)
    completed_lookup = {}
    for combo in state:
        if combo.get('status') == 'completed' and combo.get('seed') is not None:
            key = (
                combo['superprompt_idx'],
                combo.get('metaprompt_idx', -1),
                combo['seed']
            )
            completed_lookup[key] = combo
    
    print(f"  Found {len(completed_lookup)} completed renders in state file")
    
    # Find all PNGs in source directory
    png_files = list(source_path.rglob("*.png"))
    print(f"  Found {len(png_files)} PNGs in {source_dir}")
    
    organized = 0
    failed = 0
    already_organized = 0
    
    for png_path in png_files:
        # Extract metadata
        full_prompt, seed = extract_prompt_and_seed_from_png(png_path)
        
        if full_prompt is None or seed is None:
            print(f"  Warning: Could not extract metadata from {png_path.name}")
            failed += 1
            continue
        
        # Find which superprompt/metaprompt this corresponds to
        sp_idx, mp_idx = extract_super_and_metaprompt(full_prompt, superprompts, metaprompts)
        
        if sp_idx is None:
            print(f"  Warning: Could not match prompt for {png_path.name}")
            failed += 1
            continue
        
        # Check if this render is completed in state
        key = (sp_idx, mp_idx, seed)
        if key not in completed_lookup:
            print(f"  Warning: Render not found in state file (sp{sp_idx}, mp{mp_idx}, seed={seed}) for {png_path.name}")
            failed += 1
            continue
        
        combo = completed_lookup[key]
        
        # Determine output subdirectory
        if mp_idx >= 0:
            output_subdir = f"sp{sp_idx:03d}/mp{mp_idx:03d}"
        else:
            output_subdir = f"sp{sp_idx:03d}/no_meta"
        
        output_dir = target_path / output_subdir
        
        # Determine output filename
        if rename_by_seed:
            # Create filename from seed and sanitized prompts
            safe_sp = sanitize_for_filename(combo['superprompt'], 20)
            if mp_idx >= 0:
                safe_mp = sanitize_for_filename(combo['metaprompt'], 20)
                new_filename = f"{safe_sp}__{safe_mp}__seed{seed}.png"
            else:
                new_filename = f"{safe_sp}__seed{seed}.png"
        else:
            # Keep original filename
            new_filename = png_path.name
        
        output_path = output_dir / new_filename
        
        # Check if file already exists at destination
        if output_path.exists():
            print(f"  Already organized: {output_path}")
            already_organized += 1
            continue
        
        # Create output directory
        if not dry_run:
            output_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy or move the file
        if not dry_run:
            try:
                if copy_mode:
                    shutil.copy2(png_path, output_path)
                    print(f"  Copied: {png_path.name} -> {output_path}")
                else:
                    shutil.move(str(png_path), str(output_path))
                    print(f"  Moved: {png_path.name} -> {output_path}")
                organized += 1
            except Exception as e:
                print(f"  Error processing {png_path.name}: {e}")
                failed += 1
        else:
            print(f"  Would {'copy' if copy_mode else 'move'}: {png_path.name} -> {output_path}")
            organized += 1
    
    return organized, failed, already_organized

def sanitize_for_filename(text, max_len=20):
    """Sanitize text for use in filenames.
    
    Args:
        text: String to sanitize
        max_len: Maximum length of the sanitized string
    
    Returns:
        Sanitized string safe for filenames
    """
    # Remove any non-alphanumeric, non-space, non-underscore, non-dash characters
    import re
    cleaned = re.sub(r'[^\w\s-]', '', text)
    # Replace spaces with underscores
    cleaned = cleaned.replace(' ', '_')
    # Remove multiple consecutive underscores
    cleaned = re.sub(r'_+', '_', cleaned)
    # Truncate
    return cleaned[:max_len]

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
    
    # Validate at least one source (for merge)
    if not args.source_state_file and not args.source_curated_dir:
        print("Error: At least one of --source-state-file or --source-curated-dir is required")
        sys.exit(1)
    
    # Load target state file
    target_path = Path(args.merge_to_state_file)
    if not target_path.exists():
        print(f"Error: Target state file not found: {target_path}")
        sys.exit(1)
    
    print(f"\n{'='*70}")
    print(f"Processing state file: {target_path}")
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
    matched_png_files = []
    orphan_png_files = []
    
    if args.source_curated_dir:
        print(f"Processing curated directory: {args.source_curated_dir}")
        added, already, unmatched, no_metadata, no_pending, matched, orphans = merge_from_curated_dir(
            args.source_curated_dir, superprompts, metaprompts, 
            target_lookup_by_sp_mp, target_state, args.dry_run, [], []
        )
        curated_added = added
        curated_already = already
        curated_unmatched = unmatched
        curated_no_metadata = no_metadata
        curated_no_pending = no_pending
        matched_png_files = matched
        orphan_png_files = orphans
        total_added += added
        total_already += already
        print(f"  Added: {added} new completions, {already} already completed\n")
    
    # Show merge summary
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
        print(f"  PNGs that couldn't be matched (orphans): {curated_unmatched}")
    if curated_no_pending > 0:
        print(f"  PNGs with no pending slots: {curated_no_pending}")
    print(f"  ")
    print(f"  Target state after merge:")
    print(f"    Total combinations: {total_combinations}")
    print(f"    Completed: {new_completed}")
    print(f"    Pending: {total_combinations - new_completed}")
    print(f"{'='*70}")
    
    if total_added == 0 and curated_unmatched == 0:
        print("\nNo new completions to add and no orphans found.")
    elif total_added > 0:
        # Confirm and save (only if there are additions to save)
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
                print(f"\nSuccessfully updated {target_path}")
            else:
                print(f"\nFailed to save {target_path}")
                sys.exit(1)
        else:
            print(f"\nDRY RUN: No changes were saved.")
    
    # Handle file moving (matched and orphan) after state save
    if not args.dry_run and args.source_curated_dir:
        source_curated_path = Path(args.source_curated_dir)
        
        # Offer to move matched PNG files if any were merged
        if matched_png_files:
            print(f"\nThe following {len(matched_png_files)} PNG files were matched and merged:")
            
            # Show first 10 as examples
            for f in matched_png_files[:10]:
                print(f"  {f}")
            if len(matched_png_files) > 10:
                print(f"  ... and {len(matched_png_files) - 10} more")
            
            print(f"\nThese files can be moved to your target output directory")
            print(f"if needed, to organize them and complete the merge process.")
            print(f"\nYou will be prompted for the target directory path.")
            print(f"Files will be MOVED (not copied) to preserve the relative")
            print(f"subdirectory structure from the source curated directory.")
            
            move_response = input(f"\nMove these files to target output directory? (y/N): ").strip().lower()
            if move_response == 'y':
                target_output = input(f"\nEnter target output directory path: ").strip()
                if target_output:
                    target_output_path = Path(target_output)
                    if target_output_path.exists():
                        moved_count = 0
                        for src_path in matched_png_files:
                            src = Path(src_path)
                            try:
                                rel_path = src.relative_to(source_curated_path)
                                dst = target_output_path / rel_path
                                dst.parent.mkdir(parents=True, exist_ok=True)
                                shutil.move(str(src), str(dst))
                                moved_count += 1
                            except ValueError:
                                dst = target_output_path / src.name
                                shutil.move(str(src), str(dst))
                                moved_count += 1
                            except Exception as e:
                                print(f"  Failed to move {src.name}: {e}")
                        print(f"\nMoved {moved_count} files to {target_output_path}")
                    else:
                        print(f"Target directory not found: {target_output}")
                        print("Files not moved. Move them manually.")
                else:
                    print("No target directory provided. Files not moved.")
            else:
                print("Files not moved. Move them manually to complete the merge.")
        
        # Offer to move orphan PNG files (unmatched) to _discards/_orphans
        if orphan_png_files:
            print(f"\nThe following {len(orphan_png_files)} PNG files could not be matched")
            print(f"to any state entry (orphans):")
            
            # Show first 10 as examples
            for f in orphan_png_files[:10]:
                print(f"  {f}")
            if len(orphan_png_files) > 10:
                print(f"  ... and {len(orphan_png_files) - 10} more")
            
            print(f"\nThese files can be moved to '_discards/_orphans' subfolder to keep")
            print(f"your curated directory clean.")
            
            orphan_response = input(f"\nMove orphans to '_discards/_orphans'? (y/N): ").strip().lower()
            if orphan_response == 'y':
                discards_dir = source_curated_path / "_discards"
                orphans_dir = discards_dir / "_orphans"
                orphans_dir.mkdir(parents=True, exist_ok=True)
                
                moved_orphans = 0
                for src_path in orphan_png_files:
                    src = Path(src_path)
                    try:
                        rel_path = src.relative_to(source_curated_path)
                        dst = orphans_dir / rel_path
                        dst.parent.mkdir(parents=True, exist_ok=True)
                        shutil.move(str(src), str(dst))
                        moved_orphans += 1
                    except Exception as e:
                        print(f"  Failed to move {src.name}: {e}")
                
                print(f"\nMoved {moved_orphans} orphan files to {orphans_dir}")
                
                # Offer to delete empty directories left behind
                if moved_orphans > 0:
                    cleanup = input(f"\nRemove empty source directories left behind? (y/N): ").strip().lower()
                    if cleanup == 'y':
                        for root, dirs, files in os.walk(source_curated_path, topdown=False):
                            for dir_name in dirs:
                                dir_path = Path(root) / dir_name
                                # Skip the _discards directory itself
                                if dir_path == discards_dir or dir_path.parent == discards_dir:
                                    continue
                                if not any(dir_path.iterdir()):
                                    dir_path.rmdir()
                                    print(f"  Removed empty directory: {dir_path}")
            else:
                print("Orphans not moved. You may delete them manually.")
    
    # Offer to organize completed renders (if source_curated_dir exists and not dry run)
    if args.source_curated_dir and not args.dry_run:
        print(f"\n{'='*70}")
        print(f"ORGANIZE COMPLETED RENDERS")
        print(f"{'='*70}\n")
        
        print(f"Now that the state file has been updated, you can organize")
        print(f"the PNG files that are marked as completed in the state file.")
        print(f"If you do, you will be prompted for the directory to move and")
        print(f"organize them into.")
        print(f"Source directory: {args.source_curated_dir}")
        
        organize_response = input(f"\nOrganize completed renders into proper spXXX/mpYYY/ structure? (y/N): ").strip().lower()
        
        if organize_response == 'y':
            # Prompt for target directory
            organize_target = input(f"\nEnter target directory to organize into: ").strip()
            if not organize_target:
                print("Organization cancelled - no target directory provided.")
            else:
                # Prompt for copy vs move
                copy_response = input(f"\nCopy files (keep originals) or move? (c=Copy, m=Move) [m]: ").strip().lower()
                copy_mode = (copy_response == 'c')
                
                # Prompt for rename option
                rename_response = input(f"\nRename files using seed in filename? (y/N): ").strip().lower()
                rename_by_seed = (rename_response == 'y')
                
                print(f"\nOrganizing completed renders:")
                print(f"  Source: {args.source_curated_dir}")
                print(f"  Target: {organize_target}")
                print(f"  Mode: {'Copy' if copy_mode else 'Move'}")
                print(f"  Rename by seed: {'Yes' if rename_by_seed else 'No'}")
                
                if not args.force:
                    confirm = input(f"\nProceed? (y/N): ").strip().lower()
                    if confirm != 'y':
                        print("Organization cancelled.")
                    else:
                        organized, failed, already = organize_completed_renders(
                            target_state, superprompts, metaprompts,
                            args.source_curated_dir, organize_target,
                            copy_mode=copy_mode,
                            rename_by_seed=rename_by_seed,
                            dry_run=False
                        )
                        
                        print(f"\nORGANIZATION SUMMARY")
                        print(f"  Organized: {organized}")
                        print(f"  Already organized: {already}")
                        print(f"  Failed: {failed}")
                else:
                    organized, failed, already = organize_completed_renders(
                        target_state, superprompts, metaprompts,
                        args.source_curated_dir, organize_target,
                        copy_mode=copy_mode,
                        rename_by_seed=rename_by_seed,
                        dry_run=False
                    )
                    
                    print(f"\nORGANIZATION SUMMARY")
                    print(f"  Organized: {organized}")
                    print(f"  Already organized: {already}")
                    print(f"  Failed: {failed}")
        else:
            print("Organization skipped.")
    
    if args.dry_run:
        print(f"\nDRY RUN: No changes were saved and no files were moved.")
        print(f"To actually apply changes, run without --dry-run")

if __name__ == "__main__":
    main()