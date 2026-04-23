#!/usr/bin/env python3
"""
SCRIPT: refine_prompts_from_curated.py
VERSION: 1.2.9

DESCRIPTION:
    Prompt Refinement Tool for ComfyUI Batch Runner Workflow
    Scans a folder of kept PNGs (the ones you did NOT delete after a batch render),
    extracts the positive prompts from PNG metadata, and generates ranked prompt files.
    When used with the state pickle file from comfyUIbatchRunner.py, it calculates win
    rates (kept / total rendered) and ranks prompts accordingly. Without the state file,
    it falls back to occurrence‑based ranking.

    This script completes the iterative prompt development loop:
        1. Run comfyUIbatchRunner.py to generate many images.
        2. Curate by deleting unwanted images directly inside the output folder.
        3. Run this script to get ranked superprompts, metaprompts, and full prompts.
           Optionally filtered to only those used in curated files (see USAGE).
        4. Use the ranked files as input for the next batch run.

DEPENDENCIES:
    Python 3.6 or higher
    Pillow (PIL) library (pip install Pillow)

USAGE:
    python refine_prompts_from_curated.py --curated-dir ./renders

REQUIRED ARGUMENTS:
    --curated-dir PATH          Folder containing kept PNGs (scans recursively)

OPTIONAL ARGUMENTS:
    --state-file FILE           Path to .pkl state file from comfyUIbatchRunner.py
                                (default: .comfyUIbatchRunner_render_state.pkl)
                                If provided, win rates are calculated.
    --original-super FILE       Original superprompts file (default: superprompts.txt)
    --original-meta FILE        Original metaprompts file (default: metaprompts.txt)
    --output-super FILE         Custom output for ranked superprompts
                                (default: {original_super_basename}_ranked_TIMESTAMP.txt)
    --output-meta FILE          Custom output for ranked metaprompts
                                (default: {original_meta_basename}_ranked_TIMESTAMP.txt)
    --output-pairs FILE         Custom output for superduperprompts (full prompts)
                                (default: superduperprompts_TIMESTAMP.txt)
    --only-write-used-prompts   When used together with --state-file, the output superprompts
                                and metaprompts files will contain only prompts that are in the
                                curated set (have at least one kept image). Prompts do not
                                appear in any of the curated set are omitted. Useful for
                                creating a minimal, focused prompt set for another iteration
                                or more renders, discarding "dead" prompts that never produced
                                a keeper. (default: False, writes all original prompts sorted
                                by win rate)

FILE REQUIREMENTS:
    superprompts.txt (or custom)    One template per line, use '{}' as placeholder.
                                    Example: "expressive abstract {}, bold brushstrokes"
    metaprompts.txt (or custom)     One value per line, inserted into '{}'.
                                    Example: "vibrant crimson red"
    The files should match those used when generating the images. The script matches
    prompts by full text, not by index, so you can safely add/remove lines after
    a batch run (unlike the batch runner's state file).

NOTES:
    METADATA EXTRACTION:
        The script reads the 'prompt' field from PNG metadata (embedded by ComfyUI).
        It looks for a CLIPTextEncode node whose title contains "Prompt Positive"
        (case‑insensitive) and extracts the 'text' input.

    WIN RATE CALCULATION (with --state-file):
        Win rate = (number of kept images for a prompt) / (total rendered images for that prompt)
        Prompts that were never rendered (total = 0) get a win rate of 0.0 and appear at
        the bottom of the ranked lists. If --only-write-used-prompts is given, such prompts
        are omitted entirely from the output files. NOTE that this calculation gives a
        more accurate idea of what may be considered a more popular result, because
        it tracks total renders noted in the state file whether those renders are in the
        scanned curated PNG (render) set or not, and uses those for calculating rank.

    OCCURRENCE FALLBACK (without --state-file):
        Ranks prompts purely by how many kept images contain them.
        Useful when you no longer have the original state file or want a quick frequency list.
        Note: --only-write-used-prompts is inapplicable in this mode, because the
        fallback writes prompts that appear in the curated set without any knowledge of
        whether those prompts were in a state file. NOTE that this fallback provides a
        potentially less accurate picture of what may be more popular, because it doesn't
        use any state file knowledge of prior renders (see WIN RATE CALCULATION).

    OUTPUT FILES:
        * Ranked superprompts:     One template per line, sorted by win rate (descending).
        * Ranked metaprompts:      One value per line, sorted by win rate.
        * Superduperprompts:       Full prompts (template + metaprompt) for every winning
                                   combination, ready to be used as a superprompts file
                                   with an empty metaprompts file (--metaprompts empty.txt).

    MATCHING LOGIC:
        For a full prompt like "expressive abstract vibrant crimson red, bold brushstrokes":
        - The script checks each superprompt template, e.g. "expressive abstract {}, bold..."
        - It extracts the part that replaces '{}' ("vibrant crimson red").
        - If that extracted part exists in the metaprompts list (or is empty when allowed),
          the match is considered successful.

    EMPTY METAPROMPTS:
        If the original metaprompts file was empty (treated as a single empty string),
        the script handles that correctly: it looks for pairs where the extracted part
        is an empty string and matches accordingly.

EXAMPLES:
    # Basic usage (occurrence ranking, no state file)
    python refine_prompts_from_curated.py --curated-dir ./renders

    # Full win‑rate ranking using state file
    python refine_prompts_from_curated.py --curated-dir ./renders \\
        --state-file .comfyUIbatchRunner_render_state.pkl

    # Only write prompts that actually produced kept images
    python refine_prompts_from_curated.py --curated-dir ./renders \\
        --state-file state.pkl --only-write-used-prompts

    # Custom input/output files
    python refine_prompts_from_curated.py --curated-dir ./my_kept \\
        --original-super my_super.txt --original-meta my_meta.txt \\
        --output-super top_super.txt --output-meta top_meta.txt

    # Use the output in a new batch run (superprompts only, no metaprompt mixing)
    echo "" > empty.txt
    python comfyUIbatchRunner.py -w workflow.json \\
        --superprompts superduperprompts_20260115_1430.txt \\
        --metaprompts empty.txt -s 3

TROUBLESHOOTING:
    - "No PNG files found": Ensure --curated-dir points to the correct folder and
      contains .png files (maybe in subfolders).
    - "Could not read PNG": The file may be corrupt or not a valid PNG.
    - Prompts not matching: Verify that the --original-super and --original-meta files
      exactly match those used when generating the images (identical line‑by‑line text).
    - Win rates all zero: The state file may be from a different run; make sure it
      corresponds to the same prompt files and that the renders were actually completed.

CODE:
"""

import argparse
import json
import pickle
import sys
from pathlib import Path
from collections import Counter, defaultdict
from datetime import datetime
from PIL import Image

def extract_prompt_from_png(png_path):
    """Extract the positive prompt from PNG metadata"""
    try:
        with Image.open(png_path) as img:
            metadata = img.text
            if 'prompt' in metadata:
                workflow = json.loads(metadata['prompt'])
                for node_id, node_data in workflow.items():
                    if node_data.get('class_type') == 'CLIPTextEncode':
                        title = node_data.get('_meta', {}).get('title', '')
                        if 'Prompt Positive' in title:
                            return node_data.get('inputs', {}).get('text', '')
                # Fallback
                for node_id, node_data in workflow.items():
                    if node_data.get('class_type') == 'CLIPTextEncode':
                        title = node_data.get('_meta', {}).get('title', '').lower()
                        if 'positive' in title:
                            return node_data.get('inputs', {}).get('text', '')
            return None
    except Exception as e:
        print(f"Warning: Could not read {png_path}: {e}")
        return None

def extract_super_and_metaprompt(full_prompt, superprompts, metaprompts):
    """
    Reverse-engineer which superprompt template and metaprompt produced this full prompt.
    Returns (superprompt, metaprompt) or (None, None)
    """
    for sp in superprompts:
        if '{}' in sp:
            # Try to extract metaprompt by replacing the placeholder
            parts = sp.split('{}')
            if len(parts) == 2:
                # Check if full_prompt starts with parts[0] and ends with parts[1]
                if full_prompt.startswith(parts[0]) and full_prompt.endswith(parts[1]):
                    metaprompt_candidate = full_prompt[len(parts[0]):-len(parts[1])] if parts[1] else full_prompt[len(parts[0]):]
                    # Handle empty metaprompt case
                    if metaprompt_candidate == "" and not metaprompts:
                        return sp, ""
                    if metaprompt_candidate in metaprompts:
                        return sp, metaprompt_candidate
        else:
            # No placeholder - direct match
            if full_prompt == sp:
                return sp, None
    return None, None

def get_output_filename(base_name, extension, timestamp):
    """Generate output filename with timestamp"""
    return f"{base_name}_{timestamp}{extension}"

def main():
    parser = argparse.ArgumentParser(description='Refine prompts from curated images')
    parser.add_argument('--curated-dir', required=True, help='Path to folder with PNGs (typically the output dir from batch runner)')
    parser.add_argument('--state-file', default='.comfyUIbatchRunner_render_state.pkl', help='Path to .pkl state file')
    parser.add_argument('--original-super', default='superprompts.txt', help='Original superprompts file')
    parser.add_argument('--original-meta', default='metaprompts.txt', help='Original metaprompts file')
    parser.add_argument('--output-super', help='Output file for ranked superprompts (default: {original_super_basename}_ranked_TIMESTAMP.txt)')
    parser.add_argument('--output-meta', help='Output file for ranked metaprompts (default: {original_meta_basename}_ranked_TIMESTAMP.txt)')
    parser.add_argument('--output-pairs', help='Output file for superduperprompts (default: superduperprompts_TIMESTAMP.txt)')
    parser.add_argument('--only-write-used-prompts', action='store_true',
                        help='--only-write-used-prompts and --state-file: write only those superprompts and metaprompts'
                             'that actually appear in the curated images (i.e., have kept_count > 0), sorted by most kept (win rate).'
                             '--state-file only (no --only~) : all original prompts are written, also by win rate.'
                             'No --only~ or --state-file: fallback, only used prompts are written, ranked by occurrence count.')
    
    args = parser.parse_args()
    
    curated_dir = Path(args.curated_dir)
    if not curated_dir.exists():
        print(f"Error: Curated directory not found: {curated_dir}")
        sys.exit(1)
    
    # Generate timestamp for default filenames
    timestamp = datetime.now().strftime("%Y%m%d_%H%M")
    
    # Set output filenames with timestamps if not specified
    if args.output_super:
        output_super = args.output_super
    else:
        original_super_base = Path(args.original_super).stem
        output_super = get_output_filename(f"{original_super_base}_ranked", ".txt", timestamp)
    
    if args.output_meta:
        output_meta = args.output_meta
    else:
        original_meta_base = Path(args.original_meta).stem
        output_meta = get_output_filename(f"{original_meta_base}_ranked", ".txt", timestamp)
    
    if args.output_pairs:
        output_pairs = args.output_pairs
    else:
        output_pairs = get_output_filename("superduperprompts", ".txt", timestamp)
    
    # Load original prompts for matching
    try:
        with open(args.original_super, 'r', encoding='utf-8') as f:
            superprompts = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: Original superprompts file not found: {args.original_super}")
        sys.exit(1)
    
    try:
        with open(args.original_meta, 'r', encoding='utf-8') as f:
            metaprompts = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Warning: Original metaprompts file not found: {args.original_meta}")
        metaprompts = []
    
    # Load state file if it exists
    render_state = None
    if Path(args.state_file).exists():
        try:
            with open(args.state_file, 'rb') as f:
                render_state = pickle.load(f)
            print(f"Loaded state file: {args.state_file}")
        except Exception as e:
            print(f"Warning: Could not load state file: {e}")
            print("Continuing without state file - will use occurrence counts only (no win rates)")
    
    # Find all PNGs recursively
    png_files = list(curated_dir.rglob("*.png"))
    print(f"Found {len(png_files)} PNGs in {curated_dir}")
    
    if not png_files:
        print("Error: No PNG files found in curated directory")
        sys.exit(1)
    
    # Extract prompts and build statistics
    superprompt_counts = Counter()  # Kept counts
    metaprompt_counts = Counter()   # Kept counts
    pair_counts = Counter()         # Kept counts for (sp_idx, mp_idx)
    
    # Also track which indices correspond to which prompts
    superprompt_to_idx = {sp: idx for idx, sp in enumerate(superprompts)}
    metaprompt_to_idx = {mp: idx for idx, mp in enumerate(metaprompts)} if metaprompts else {}
    
    # For storing which prompts we found
    found_superprompts = set()
    found_metaprompts = set()
    found_pairs = set()
    
    for png_path in png_files:
        full_prompt = extract_prompt_from_png(png_path)
        if full_prompt:
            sp, mp = extract_super_and_metaprompt(full_prompt, superprompts, metaprompts)
            if sp:
                superprompt_counts[sp] += 1
                found_superprompts.add(sp)
                
                if mp is not None:
                    metaprompt_counts[mp] += 1
                    found_metaprompts.add(mp)
                    pair_counts[(sp, mp)] += 1
                    found_pairs.add((sp, mp))
                elif not metaprompts:
                    # Handle case where metaprompts file was empty
                    pair_counts[(sp, "")] += 1
                    found_pairs.add((sp, ""))
    
    # If state file is available, calculate win rates
    if render_state:
        # Build total rendered counts from state file
        superprompt_total = defaultdict(int)
        metaprompt_total = defaultdict(int)
        pair_total = defaultdict(int)
        
        # Map indices back to prompt text
        idx_to_superprompt = {idx: sp for idx, sp in enumerate(superprompts)}
        idx_to_metaprompt = {idx: mp for idx, mp in enumerate(metaprompts)} if metaprompts else {}
        
        for combo in render_state:
            # Check completion status (supports current 'status' field)
            if combo.get('status') == 'completed':
                sp_idx = combo['superprompt_idx']
                sp_text = idx_to_superprompt.get(sp_idx)
                if sp_text:
                    superprompt_total[sp_text] += 1
                    
                    mp_idx = combo.get('metaprompt_idx', -1)
                    if metaprompts and mp_idx >= 0:
                        mp_text = idx_to_metaprompt.get(mp_idx)
                        if mp_text:
                            metaprompt_total[mp_text] += 1
                            pair_total[(sp_text, mp_text)] += 1
                    elif not metaprompts:
                        # Handle empty metaprompts case
                        pair_total[(sp_text, "")] += 1
        
        # Calculate win rates
        superprompt_win_rate = {}
        for sp in superprompts:
            kept = superprompt_counts.get(sp, 0)
            total = superprompt_total.get(sp, 0)
            if total > 0:
                superprompt_win_rate[sp] = kept / total
            else:
                superprompt_win_rate[sp] = 0.0
        
        metaprompt_win_rate = {}
        for mp in metaprompts:
            kept = metaprompt_counts.get(mp, 0)
            total = metaprompt_total.get(mp, 0)
            if total > 0:
                metaprompt_win_rate[mp] = kept / total
            else:
                metaprompt_win_rate[mp] = 0.0
        
        pair_win_rate = {}
        for sp in superprompts:
            for mp in (metaprompts if metaprompts else [""]):
                kept = pair_counts.get((sp, mp), 0)
                total = pair_total.get((sp, mp), 0)
                if total > 0:
                    pair_win_rate[(sp, mp)] = kept / total
        
        # Rank by win rate (higher is better)
        ranked_superprompts = sorted(superprompts, key=lambda sp: superprompt_win_rate.get(sp, 0), reverse=True)
        ranked_metaprompts = sorted(metaprompts, key=lambda mp: metaprompt_win_rate.get(mp, 0), reverse=True)
        
        # Apply --only-write-used-prompts filtering if requested
        if args.only_write_used_prompts:
            ranked_superprompts = [sp for sp in ranked_superprompts if sp in found_superprompts]
            ranked_metaprompts = [mp for mp in ranked_metaprompts if mp in found_metaprompts]
            print(f"Filtering: Only writing used prompts (kept_count > 0)")
        
        # Filter pairs to only those that were actually kept (winning combinations)
        winning_pairs = [(sp, mp) for (sp, mp) in found_pairs if pair_win_rate.get((sp, mp), 0) > 0]
        ranked_pairs = sorted(winning_pairs, key=lambda pair: pair_win_rate.get(pair, 0), reverse=True)
        
        # Generate full prompts for superduperprompts
        superduperprompts = []
        for sp, mp in ranked_pairs:
            if mp == "":
                full_prompt = sp.replace('{}', '').strip()
            else:
                full_prompt = sp.replace('{}', mp)
            superduperprompts.append(full_prompt)
        
        # Print statistics
        print(f"\n{'='*60}")
        print(f"Prompt Refinement Complete (with win rates)")
        print(f"  Using state file: {args.state_file}")
        print(f"\n  Original superprompts: {len(superprompts)}")
        print(f"  Ranked superprompts: {len(ranked_superprompts)}")
        print(f"\n  Original metaprompts: {len(metaprompts)}")
        print(f"  Ranked metaprompts: {len(ranked_metaprompts)}")
        print(f"\n  Superduperprompts generated: {len(superduperprompts)}")
        
        # Show top 5 superprompts
        print(f"\nTop 5 superprompts by win rate:")
        for i, sp in enumerate(ranked_superprompts[:5], 1):
            kept = superprompt_counts.get(sp, 0)
            total = superprompt_total.get(sp, 0)
            rate = superprompt_win_rate.get(sp, 0)
            print(f"  {i}. {rate:.1%} ({kept}/{total}) - {sp[:60]}...")
        
        # Show top 5 metaprompts
        if ranked_metaprompts:
            print(f"\nTop 5 metaprompts by win rate:")
            for i, mp in enumerate(ranked_metaprompts[:5], 1):
                kept = metaprompt_counts.get(mp, 0)
                total = metaprompt_total.get(mp, 0)
                rate = metaprompt_win_rate.get(mp, 0)
                print(f"  {i}. {rate:.1%} ({kept}/{total}) - {mp[:60]}...")
        
        # Write output files
        with open(output_super, 'w', encoding='utf-8') as f:
            for sp in ranked_superprompts:
                f.write(sp + '\n')
        
        with open(output_meta, 'w', encoding='utf-8') as f:
            for mp in ranked_metaprompts:
                f.write(mp + '\n')
        
        with open(output_pairs, 'w', encoding='utf-8') as f:
            for prompt in superduperprompts:
                f.write(prompt + '\n')
        
        print(f"\n  Output files:")
        print(f"    {output_super}")
        print(f"    {output_meta}")
        print(f"    {output_pairs}")
    
    else:
        # Fallback: simple occurrence counts (no win rates)
        print(f"\n{'='*60}")
        print(f"Prompt Refinement Complete (occurrence counts only - no state file)")
        print(f"  (To calculate win rates, provide a valid state file with --state-file)")
        
        # Rank by occurrence count (higher is better)
        ranked_superprompts = sorted(found_superprompts, key=lambda sp: superprompt_counts.get(sp, 0), reverse=True)
        ranked_metaprompts = sorted(found_metaprompts, key=lambda mp: metaprompt_counts.get(mp, 0), reverse=True)
        
        # Generate superduperprompts from found pairs
        superduperprompts = []
        for sp, mp in sorted(found_pairs, key=lambda pair: pair_counts.get(pair, 0), reverse=True):
            if mp == "":
                full_prompt = sp.replace('{}', '').strip()
            else:
                full_prompt = sp.replace('{}', mp)
            superduperprompts.append(full_prompt)
        
        print(f"\n  Original superprompts: {len(superprompts)}")
        print(f"  Ranked superprompts: {len(ranked_superprompts)}")
        print(f"\n  Original metaprompts: {len(metaprompts)}")
        print(f"  Ranked metaprompts: {len(ranked_metaprompts)}")
        print(f"\n  Superduperprompts generated: {len(superduperprompts)}")
        
        # Show top 5
        print(f"\nTop 5 superprompts by occurrence:")
        for i, sp in enumerate(ranked_superprompts[:5], 1):
            count = superprompt_counts.get(sp, 0)
            print(f"  {i}. {count} images - {sp[:60]}...")
        
        # Write output files
        with open(output_super, 'w', encoding='utf-8') as f:
            for sp in ranked_superprompts:
                f.write(sp + '\n')
        
        with open(output_meta, 'w', encoding='utf-8') as f:
            for mp in ranked_metaprompts:
                f.write(mp + '\n')
        
        with open(output_pairs, 'w', encoding='utf-8') as f:
            for prompt in superduperprompts:
                f.write(prompt + '\n')
        
        print(f"\n  Output files:")
        print(f"    {output_super}")
        print(f"    {output_meta}")
        print(f"    {output_pairs}")
    
    print(f"{'='*60}")

if __name__ == "__main__":
    main()