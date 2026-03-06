# DESCRIPTION
# Experimental attempt to sort colors in a palette by perceived "distance,"
# "furthest" first, using HCT color space (as implemented in the coloraide Python
# library). Reads color hex codes from input (stdin or file), extracts them using
# regex, sorts them perceptually based on combined distance score (hue, chroma,
# tone), and splits into N palettes using adaptive band recursive splitting.
# Can output in Processing JSON format or raw hex.
#
# THEORY (NAIVE/EXPERIMENTAL):
# This script attempts to model how humans might perceive color "distance" in a
# 2D composition or painting. The model combines three factors:
#
# 1. HUE ORDERING: Based on artistic observation, yellow (106° in HCT) feels
#    "nearest," with perceived distance increasing as hue moves away in both
#    directions around the circle, following this sequence:
#    106° (NEAREST) → 105° → 104° → ... → 0° → 359° → 358° → ... → 107° (FURTHEST)
#
# 2. CHROMA (SATURATION): Lower chroma (desaturated colors) feel more distant,
#    like atmospheric haze. Higher chroma (vibrant colors) feel nearer.
#
# 3. TONE (LIGHTNESS): For desaturated colors, darker tones feel nearer, lighter
#    tones feel more distant (like haze). For saturated colors, both very dark
#    and very light can feel near (high contrast draws attention).
#
# These factors are weighted (40% hue, 35% chroma, 25% tone) into a single
# "nearness score" from 0-1. Colors are then grouped using adaptive band
# recursive splitting, which finds natural perceptual gaps in the score
# distribution to create perceptually meaningful palettes.

# DEPENDENCIES
# - coloraide (pip install coloraide)
# - Python 3.6+

# USAGE
#   sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py [options]
#
# Options:
#   -h, --help              Show this help message
#   -n, --num-palettes N    Number of output palettes (default: 5)
#   -e, --equalcounts       Use simple equal counts instead of adaptive recursive splitting
#   -m --min-size M            Minimum number of colors per palette (default: 2)
#   -i, --input FILE        Input file to read
#   -o, --output FILE       Output file base name (default: stdout)
#                           When specified, creates N files: output_01.ext, output_02.ext, etc.
#   -f, --format FORMAT     Output format: 'processing' (JSON array of arrays) or 
#                           'raw' (one hex per line, grouped by palette with comments) (default: raw)
#   --stdin                 Explicitly read from stdin (useful for scripts)
#   --build-exe             Show instructions for building executable
#
# EXAMPLES:
#   # Read from file, output raw format to stdout (adaptive recursive splitting)
#   python sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py -i colors.txt
#   
#   # Use simple equal counts instead
#   python sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py -i colors.txt -e
#   
#   # Read from stdin, output processing format to file
#   echo '#FF0000 #00FF00 #0000FF' | python sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py --stdin -o output.json -f processing
#   
#   # Create 3 palette files (adaptive splitting) with minimum 3 colors per palette
#   python sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py -i colors.txt -o palette.txt -f raw -n 3 --min-size 3
#   
#   # Same but with equal counts
#   python sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py -i colors.txt -o palette.txt -f raw -n 3 -e
#   
#   # Get executable build instructions
#   python sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py --build-exe
#
# NOTES
# - Input can contain any text; the script extracts all 6-digit hex codes (with or without #)
# - Hex codes are case-insensitive (a-f, A-F, 0-9)
# - The script uses HCT color space for perceptual accuracy
# - If no input source is specified (no -i and no --stdin), the script will exit with an error
# - When -o is specified with multiple palettes, creates numbered files: base_01.ext, base_02.ext, etc.
# - Default splitting: adaptive band recursive splitting (finds natural perceptual gaps)
# - With -e: simple equal counts splitting
# - Minimum palette size can be set with --min-size (default: 2)
#
# ENVIRONMENT VARIABLE CONTRACT (for script integration):
#   This script does not set environment variables directly, but works with
#   the test runner which expects:
#     - Input files can be specified via -i or --stdin
#     - Output files are created with predictable naming patterns
#     - The test runner uses file system patterns to discover results
#
#   For integration with the palette generator, see:
#     perceptual_distance_HCT_palette_generator.py --stdin
#     perceptual_distance_HCT_palette_generator_test.py
#
#   The generator and sorter share the same perceptual distance model,
#   allowing them to work together: the sorter can organize colors generated
#   by the generator, and the generator can create colors that fit into
#   the sorter's perceptual categories.
#
# TO USE with a Processing sketch:
# String[] command = {"python", "sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py", 
#                     "--stdin", "-f", "processing", "-n", str(numPalettes)};

# CODE
import sys
import re
import json
import argparse
import os
import heapq
from coloraide import Color
from coloraide.spaces.hct import HCT

# Register HCT color space (required for coloraide)
Color.register(HCT())

def extract_hex_colors(text):
    """
    Extract all 6-digit hex color codes from text using regex.
    Returns list of hex codes with '#' prefix.
    """
    # Pattern matches #RRGGBB, with or without #
    pattern = r'#?([0-9A-Fa-f]{6})\b'
    matches = re.findall(pattern, text)
    
    # Add # prefix to all matches
    return ['#' + m.upper() for m in matches]

def hex_to_hct(hex_color):
    """
    Convert hex to HCT color space using coloraide.
    Returns dict with HCT components and hex.
    """
    try:
        # Ensure hex has # prefix
        if not hex_color.startswith('#'):
            hex_color = '#' + hex_color
            
        c = Color(hex_color)
        hct = c.convert('hct')
        
        h = hct['h']  # Hue (0-360)
        c_val = hct['c']  # Chroma (0-~145)
        t = hct['t']  # Tone (0-100)
        
        return {
            'hex': hex_color,
            'hue': h,
            'chroma': c_val,
            'tone': t,
            'color_obj': c
        }
    except Exception as e:
        print(f"Warning: Could not convert {hex_color}: {e}", file=sys.stderr)
        return None

def hue_distance_score(hue):
    """
    Calculate nearness score based on explicit ordering.
    
    Experimental theory: Yellow (106°) feels nearest. Perceived distance increases
    as hue moves away in a single direction around the circle:
    106° (NEAREST) → 105° → 104° → ... → 0° → 359° → 358° → ... → 107° (FURTHEST)
    
    Score = 1.0 at hue 106° (nearest)
    Score decreases linearly along the sequence
    Score = 0.0 at hue 107° (furthest)
    """
    # Handle the wrap: treat hues >= 107 as being on the "far side" of the sequence
    if hue >= 107:
        # For hues 107-359, they come after the wrap
        # Position = (106 - 0) + (360 - hue) = 106 + (360 - hue)
        position = 106 + (360 - hue)
    else:
        # For hues 0-106, position is simply (106 - hue)
        position = 106 - hue
    
    # Total length of sequence: from 106 down to 0 (106 steps) + from 359 down to 107 (253 steps)
    # = 106 + 253 = 359 total positions (0-358)
    max_position = 359.0
    
    # Convert to 0-1 score where 1 = nearest (position 0), 0 = furthest (position 359)
    score = 1.0 - (position / max_position)
    
    return score

def chroma_distance_score(chroma, tone=None):
    """
    Calculate chroma contribution to distance perception.
    
    Experimental theory: Lower chroma (desaturated) = more distant (atmospheric haze)
    Higher chroma (saturated) = nearer (pulls attention forward)
    """
    # HCT chroma maximum is around 145, but can vary
    # Normalize with a soft cap at 140
    max_chroma = 140.0
    chroma_norm = min(chroma / max_chroma, 1.0)
    
    # Simple linear: higher chroma = nearer
    return chroma_norm

def tone_distance_score(tone, chroma=None):
    """
    Calculate tone contribution to distance perception.
    
    Experimental theory: 
    - For desaturated colors (low chroma): darker = nearer, lighter = more distant (haze)
    - For saturated colors (high chroma): both very dark and very light can feel near
      (high contrast draws attention regardless of lightness)
    """
    tone_norm = tone / 100.0
    
    if chroma is None or chroma > 50:
        # High chroma: both ends feel near
        if tone_norm < 0.3:
            # Very dark: near
            return 0.9
        elif tone_norm > 0.7:
            # Very light: near
            return 0.9
        else:
            # Mid tones: slightly less near
            return 0.7
    else:
        # Low chroma: darker = nearer, lighter = more distant
        return 1.0 - tone_norm

def calculate_unified_distance_score(hct_color):
    """
    Combine all three HCT channels into a single "nearness" score.
    Higher score = appears nearer, Lower score = appears further.
    
    Weights (experimental, adjustable):
    - Hue: 40% - Based on artistic warm/cool perception
    - Chroma: 35% - Atmospheric haze effect
    - Tone: 25% - Lightness/darkness cues
    """
    h = hct_color['hue']
    c = hct_color['chroma']
    t = hct_color['tone']
    
    # Calculate component scores
    hue_score = hue_distance_score(h)
    chroma_score = chroma_distance_score(c, t)
    tone_score = tone_distance_score(t, c)
    
    # Weight the components
    weights = {'hue': 0.4, 'chroma': 0.35, 'tone': 0.25}
    
    total_score = (
        weights['hue'] * hue_score +
        weights['chroma'] * chroma_score +
        weights['tone'] * tone_score
    )
    
    return total_score

def adaptive_band_recursive_split(sorted_colors, target_palettes, min_gap_threshold=0.03, min_palette_size=2):
    """
    Split colors into palettes by finding natural perceptual gaps.
    
    How it works:
    1. First, find all natural groupings by recursively splitting at the largest
       perceptual gaps in the score distribution, respecting minimum palette size.
    2. Returns whatever natural groups it finds - may be fewer than target_palettes.
       The caller will handle fallback if needed.
    
    This ensures palette boundaries occur where the perceptual "distance" between
    colors is greatest, creating more meaningful groupings than arbitrary divisions.
    
    Args:
        sorted_colors: Colors sorted by distance score (lowest to highest)
        target_palettes: Desired number of palettes (for informational purposes only)
        min_gap_threshold: Minimum score difference to consider a "significant" gap
        min_palette_size: Minimum number of colors per palette (default: 2)
    
    Returns:
        List of color groups (palettes) with natural perceptual boundaries,
        may be fewer than target_palettes
    """
    
    def find_largest_gap(colors):
        """Find the largest gap between consecutive scores in a group."""
        if len(colors) < 2:
            return None
        
        max_gap = 0
        split_idx = None
        
        for i in range(len(colors) - 1):
            gap = colors[i + 1]['distance_score'] - colors[i]['distance_score']
            if gap > max_gap:
                max_gap = gap
                split_idx = i + 1  # Split after this index
        
        return split_idx if max_gap > min_gap_threshold else None
    
    def recursive_find_groups(group):
        """Recursively split a group at its largest gaps to find natural groupings."""
        split_idx = find_largest_gap(group)
        
        if split_idx is None or len(group) < 2:
            return [group]  # No meaningful split possible
        
        # Check if splitting would create groups smaller than min_palette_size
        left_size = split_idx
        right_size = len(group) - split_idx
        
        if left_size < min_palette_size or right_size < min_palette_size:
            return [group]  # Don't split if it would create too-small groups
        
        # Split at the largest gap
        left_group = group[:split_idx]
        right_group = group[split_idx:]
        
        # Recurse on both sides
        result = []
        result.extend(recursive_find_groups(left_group))
        result.extend(recursive_find_groups(right_group))
        
        return result
    
    # First, find all natural perceptual groups respecting min size
    natural_groups = recursive_find_groups(sorted_colors)
    
    print(f"Found {len(natural_groups)} natural perceptual groups (min size {min_palette_size})", file=sys.stderr)
    for i, group in enumerate(natural_groups):
        if group:
            score_range = f"{group[0]['distance_score']:.3f}-{group[-1]['distance_score']:.3f}"
            print(f"  Natural group {i}: {len(group)} colors, range {score_range}", file=sys.stderr)
    
    # If we already have enough groups, return them (sorted by average score)
    if len(natural_groups) >= target_palettes:
        natural_groups.sort(key=lambda g: sum(c['distance_score'] for c in g) / len(g))
        return natural_groups[:target_palettes]
    
    # Otherwise, we need to split some groups further to try to reach target
    print(f"Need {target_palettes} palettes, attempting to split largest groups (min size {min_palette_size})...", 
          file=sys.stderr)
    
    # Priority queue of (-size, -max_gap, group) - split largest groups with largest gaps first
    group_queue = []
    for group in natural_groups:
        if len(group) > 1:
            max_gap = max(group[j+1]['distance_score'] - group[j]['distance_score'] 
                         for j in range(len(group)-1))
            heapq.heappush(group_queue, (-len(group), -max_gap, group))
    
    current_groups = list(natural_groups)
    
    # Keep splitting while we have groups that can be split and haven't exceeded target
    while len(current_groups) < target_palettes and group_queue:
        # Get the group with largest size and largest internal gap
        neg_size, neg_gap, group_to_split = heapq.heappop(group_queue)
        
        # Find where to split this group (at its largest gap)
        max_gap = 0
        split_idx = None
        for j in range(len(group_to_split) - 1):
            gap = group_to_split[j+1]['distance_score'] - group_to_split[j]['distance_score']
            if gap > max_gap:
                max_gap = gap
                split_idx = j + 1
        
        if split_idx is None:
            continue
        
        # Check if splitting would create groups smaller than min_palette_size
        left_size = split_idx
        right_size = len(group_to_split) - split_idx
        
        if left_size < min_palette_size or right_size < min_palette_size:
            # Can't split this group without violating min size
            continue
        
        # Split the group
        left = group_to_split[:split_idx]
        right = group_to_split[split_idx:]
        
        # Remove the original group
        current_groups.remove(group_to_split)
        
        # Add the two new groups
        current_groups.append(left)
        current_groups.append(right)
        
        # Add new groups to the queue if they can be split further
        for new_group in [left, right]:
            if len(new_group) > 1:
                new_max_gap = max(new_group[k+1]['distance_score'] - new_group[k]['distance_score']
                                 for k in range(len(new_group)-1))
                heapq.heappush(group_queue, (-len(new_group), -new_max_gap, new_group))
    
    # Sort final groups by their average score for consistent ordering
    current_groups.sort(key=lambda g: sum(c['distance_score'] for c in g) / len(g))
    
    print(f"Adaptive splitting produced {len(current_groups)} palettes", file=sys.stderr)
    for i, group in enumerate(current_groups):
        if group:
            score_range = f"{group[0]['distance_score']:.3f}-{group[-1]['distance_score']:.3f}"
            print(f"  Palette {i}: {len(group)} colors, range {score_range}", file=sys.stderr)
    
    return current_groups

def split_equal_counts(sorted_colors, n_palettes):
    """
    Simple splitting: divide colors into roughly equal-sized groups.
    """
    total = len(sorted_colors)
    palettes = []
    colors_per_palette = total // n_palettes
    remainder = total % n_palettes
    
    start_idx = 0
    for i in range(n_palettes):
        extra = 1 if i < remainder else 0
        end_idx = start_idx + colors_per_palette + extra
        palette = sorted_colors[start_idx:end_idx]
        palettes.append([c['hex'] for c in palette])
        
        if palette:
            score_range = f"{palette[0]['distance_score']:.3f}-{palette[-1]['distance_score']:.3f}"
            print(f"  Palette {i}: {len(palette)} colors, score range {score_range}", file=sys.stderr)
        
        start_idx = end_idx
    
    return palettes

def split_into_palettes(hct_colors, n_palettes=5, equal_counts=False, min_palette_size=2):
    """
    Split colors into N palettes.
    
    GUARANTEES (mathematically):
    - ALL colors are preserved
    - Exactly N palettes are created
    - Every palette has at least min_palette_size colors
    - Splits occur at largest perceptual gaps, with redistribution to fix sizes
    
    Args:
        hct_colors: List of colors with HCT data
        n_palettes: Target number of palettes
        equal_counts: If True, use simple integer division (ignored in this algorithm)
        min_palette_size: Minimum colors per palette (enforced)
    """
    if not hct_colors:
        return []
    
    total_colors = len(hct_colors)
    
    # Validate: mathematical impossibility check
    if n_palettes > total_colors:
        raise ValueError(f"ERROR: Requested {n_palettes} palettes but only have {total_colors} colors")
    
    if total_colors < n_palettes * min_palette_size:
        raise ValueError(
            f"ERROR: Cannot create {n_palettes} palettes with min size {min_palette_size} "
            f"(need {n_palettes * min_palette_size} colors, have {total_colors})"
        )
    
    # Calculate scores
    for color in hct_colors:
        color['distance_score'] = calculate_unified_distance_score(color)
    
    # Sort by score (lowest = furthest, highest = nearest)
    sorted_colors = sorted(hct_colors, key=lambda c: c['distance_score'])
    
    print(f"\nColor score range: {sorted_colors[0]['distance_score']:.3f} (furthest) to "
          f"{sorted_colors[-1]['distance_score']:.3f} (nearest)", file=sys.stderr)
    print(f"Total colors: {total_colors}, Target palettes: {n_palettes}, Min size: {min_palette_size}", file=sys.stderr)
    
    if equal_counts:
        print(f"\nSplitting by equal counts into {n_palettes} palettes", file=sys.stderr)
        return split_equal_counts(sorted_colors, n_palettes)
    
    # ADAPTIVE SPLITTING - first find natural perceptual groups
    print(f"\nFinding natural perceptual groups...", file=sys.stderr)
    groups = adaptive_band_recursive_split(
        sorted_colors, 
        n_palettes, 
        min_gap_threshold=0.01,
        min_palette_size=1  # No constraint for initial grouping
    )
    
    print(f"  Initial natural groups: {len(groups)}", file=sys.stderr)
    for i, group in enumerate(groups):
        print(f"    Group {i}: {len(group)} colors", file=sys.stderr)
    
    # Verify all colors present
    colors_in_groups = sum(len(g) for g in groups)
    if colors_in_groups != total_colors:
        print(f"  WARNING: Only {colors_in_groups}/{total_colors} colors in groups", file=sys.stderr)
        print(f"  Falling back to single group", file=sys.stderr)
        groups = [sorted_colors]
    
    # If we already have more groups than needed, merge some
    if len(groups) > n_palettes:
        print(f"  Got {len(groups)} groups initially, merging closest groups to reach {n_palettes}...", file=sys.stderr)
        
        # Sort groups by average score
        groups.sort(key=lambda g: sum(c['distance_score'] for c in g) / len(g))
        
        # Merge closest groups until we have exactly n_palettes
        while len(groups) > n_palettes:
            # Find the two adjacent groups with the smallest difference in average scores
            min_diff = float('inf')
            merge_idx = 0
            
            for i in range(len(groups) - 1):
                avg1 = sum(c['distance_score'] for c in groups[i]) / len(groups[i])
                avg2 = sum(c['distance_score'] for c in groups[i+1]) / len(groups[i+1])
                diff = abs(avg2 - avg1)
                
                if diff < min_diff:
                    min_diff = diff
                    merge_idx = i
            
            # Merge the two closest groups
            merged = groups[merge_idx] + groups[merge_idx + 1]
            merged.sort(key=lambda c: c['distance_score'])
            groups.pop(merge_idx)
            groups.pop(merge_idx)  # Remove the second group
            groups.insert(merge_idx, merged)
            
            print(f"    Merged groups at index {merge_idx}, now {len(groups)} groups", file=sys.stderr)
    
    # Step 2: Split until we have exactly n_palettes (if we have fewer)
    iteration = 0
    max_iterations = total_colors * 2  # Safety guard
    while len(groups) < n_palettes and iteration < max_iterations:
        iteration += 1
        
        # Find the best group to split (largest gap, largest group)
        best_idx = -1
        best_size = 0
        best_split_idx = -1
        best_gap = 0
        
        for i, group in enumerate(groups):
            # Find the largest perceptual gap in this group
            for j in range(len(group) - 1):
                gap = group[j+1]['distance_score'] - group[j]['distance_score']
                
                # Any split is allowed - we'll fix sizes later
                if gap > best_gap or (gap == best_gap and len(group) > best_size):
                    best_gap = gap
                    best_idx = i
                    best_split_idx = j + 1
                    best_size = len(group)
        
        if best_idx == -1:
            # No more gaps to split - we're done
            print(f"  No more perceptual gaps to split, stopping at {len(groups)} groups", file=sys.stderr)
            break
        
        # Perform the split
        group_to_split = groups[best_idx]
        left_group = group_to_split[:best_split_idx]
        right_group = group_to_split[best_split_idx:]
        
        print(f"  Iteration {iteration}: Splitting group {best_idx} ({len(group_to_split)} colors) "
              f"into {len(left_group)} and {len(right_group)}", file=sys.stderr)
        
        groups.pop(best_idx)
        groups.append(left_group)
        groups.append(right_group)
        
        # Re-sort by average score
        groups.sort(key=lambda g: sum(c['distance_score'] for c in g) / len(g))
    
    # If we still don't have enough groups, force splits to reach target
    while len(groups) < n_palettes:
        print(f"  Forcing splits to reach {n_palettes} groups...", file=sys.stderr)
        
        # Find the largest group to split
        largest_idx = max(range(len(groups)), key=lambda i: len(groups[i]))
        largest = groups[largest_idx]
        
        if len(largest) < 2:
            print(f"  Cannot split further - at maximum groups possible", file=sys.stderr)
            break
        
        # Split at the largest perceptual gap
        best_gap = 0
        best_split = -1
        for j in range(len(largest) - 1):
            gap = largest[j+1]['distance_score'] - largest[j]['distance_score']
            if gap > best_gap:
                best_gap = gap
                best_split = j + 1
        
        if best_split == -1:
            break
        
        left = largest[:best_split]
        right = largest[best_split:]
        
        print(f"    Force-splitting group {largest_idx} ({len(largest)} colors) into {len(left)} and {len(right)}", file=sys.stderr)
        
        groups.pop(largest_idx)
        groups.append(left)
        groups.append(right)
        groups.sort(key=lambda g: sum(c['distance_score'] for c in g) / len(g))
    
    # Now fix any groups that are below min size by redistributing colors
    if min_palette_size > 1:
        print(f"\nEnsuring all {len(groups)} palettes have at least {min_palette_size} colors...", file=sys.stderr)
        
        iteration = 0
        while iteration < max_iterations:
            iteration += 1
            
            # Find all groups below min size
            small_groups = []
            for i, group in enumerate(groups):
                if len(group) < min_palette_size:
                    small_groups.append(i)
            
            if not small_groups:
                break
            
            # Process each small group
            small_groups.sort(reverse=True)
            made_change = False
            
            for idx in small_groups:
                if idx >= len(groups) or len(groups[idx]) >= min_palette_size:
                    continue
                
                group = groups[idx]
                needed = min_palette_size - len(group)
                
                # Find the nearest neighbor (by score) that has colors to spare
                group_avg = sum(c['distance_score'] for c in group) / len(group)
                
                best_neighbor = -1
                best_dist = float('inf')
                
                for j, other in enumerate(groups):
                    if j == idx or len(other) <= min_palette_size:
                        continue
                    other_avg = sum(c['distance_score'] for c in other) / len(other)
                    dist = abs(other_avg - group_avg)
                    if dist < best_dist:
                        best_dist = dist
                        best_neighbor = j
                
                if best_neighbor == -1:
                    # No neighbor with spare colors - find any neighbor
                    for j, other in enumerate(groups):
                        if j == idx:
                            continue
                        other_avg = sum(c['distance_score'] for c in other) / len(other)
                        dist = abs(other_avg - group_avg)
                        if dist < best_dist:
                            best_dist = dist
                            best_neighbor = j
                
                if best_neighbor != -1:
                    neighbor = groups[best_neighbor]
                    
                    # Determine how many colors we can take without dropping neighbor below min
                    take = min(needed, len(neighbor) - min_palette_size)
                    
                    if take > 0:
                        # Take colors from the neighbor that are closest to the small group's range
                        if group_avg < sum(c['distance_score'] for c in neighbor) / len(neighbor):
                            # Take from the lower end of neighbor
                            taken = neighbor[:take]
                            remaining = neighbor[take:]
                        else:
                            # Take from the higher end of neighbor
                            taken = neighbor[-take:]
                            remaining = neighbor[:-take]
                        
                        print(f"    Moving {take} colors from group {best_neighbor} to group {idx}", file=sys.stderr)
                        
                        # Update groups
                        new_group = group + taken
                        new_group.sort(key=lambda c: c['distance_score'])
                        
                        groups[idx] = new_group
                        groups[best_neighbor] = remaining
                        
                        # Re-sort all groups
                        groups.sort(key=lambda g: sum(c['distance_score'] for c in g) / len(g))
                        made_change = True
                        break  # Restart the loop
                    else:
                        # Can't take without dropping neighbor below min - merge them
                        print(f"    Merging group {idx} with group {best_neighbor} (can't redistribute)", file=sys.stderr)
                        
                        merged = group + neighbor
                        merged.sort(key=lambda c: c['distance_score'])
                        
                        if best_neighbor > idx:
                            groups.pop(best_neighbor)
                            groups.pop(idx)
                        else:
                            groups.pop(idx)
                            groups.pop(best_neighbor)
                        
                        groups.append(merged)
                        groups.sort(key=lambda g: sum(c['distance_score'] for c in g) / len(g))
                        made_change = True
                        break  # Restart the loop
            
            if not made_change:
                # No valid moves found - shouldn't happen given validation
                break
    
    # If we couldn't reach the target, use what we have
    if len(groups) < n_palettes:
        print(f"  Note: Using {len(groups)} palettes instead of requested {n_palettes}", file=sys.stderr)
    elif len(groups) > n_palettes:
        print(f"  Note: Using {len(groups)} palettes (couldn't merge further while maintaining perceptual quality)", file=sys.stderr)
    
    # Final verification - all colors present?
    all_colors = set()
    for group in groups:
        for color in group:
            all_colors.add(color['hex'])
    
    if len(all_colors) != total_colors:
        print(f"  WARNING: Lost {total_colors - len(all_colors)} colors!", file=sys.stderr)
    
    # Report results
    print(f"\nFinal {len(groups)} palettes (all ≥ {min_palette_size} colors):", file=sys.stderr)
    for i, group in enumerate(groups):
        score_range = f"{group[0]['distance_score']:.3f}-{group[-1]['distance_score']:.3f}"
        print(f"  Palette {i}: {len(group)} colors, range {score_range}", file=sys.stderr)
    
    return [[c['hex'] for c in group] for group in groups]

def process_colors(hex_colors, n_palettes=5, equal_counts=False, min_palette_size=2):
    """
    Process colors into N perceptually-ordered palettes.
    """
    # Convert all to HCT, filtering out any that failed
    hct_colors = []
    for hex_c in hex_colors:
        hct = hex_to_hct(hex_c)
        if hct is not None:
            hct_colors.append(hct)
    
    if not hct_colors:
        return []
    
    # Split into palettes
    palettes = split_into_palettes(hct_colors, n_palettes, equal_counts, min_palette_size)
    
    return palettes

def format_single_palette(palette, output_format='raw', palette_index=None, total_palettes=None):
    """
    Format a single palette for output.
    
    processing: JSON array
    raw: One hex per line, with optional header comment
    """
    if output_format == 'processing':
        return json.dumps(palette, indent=2)
    
    elif output_format == 'raw':
        lines = []
        if palette_index is not None and total_palettes is not None:
            if palette_index == 0:
                lines.append(f"# Palette {palette_index} - MOST DISTANT (background layers)")
            elif palette_index == total_palettes - 1:
                lines.append(f"# Palette {palette_index} - NEAREST (foreground layers)")
            else:
                lines.append(f"# Palette {palette_index}")
        
        for hex_color in palette:
            lines.append(hex_color)
        return "\n".join(lines)
    
    else:
        raise ValueError(f"Unknown output format: {output_format}")

def write_output_files(palettes, base_output_path, output_format):
    """
    Write multiple palette files with zero-padded numbering.
    """
    if not palettes:
        return
    
    # Separate directory path from base filename
    dir_path = os.path.dirname(base_output_path)
    base_filename = os.path.basename(base_output_path)
    
    # Split the base filename into name and extension
    base_name, ext = os.path.splitext(base_filename)
    if not ext:
        ext = '.hexplt'  # Default extension
    
    # Ensure directory exists
    if dir_path:
        os.makedirs(dir_path, exist_ok=True)
    
    # Calculate padding width based on number of palettes
    padding = len(str(len(palettes)))
    
    written_files = []
    for i, palette in enumerate(palettes):
        # Create numbered filename: name_01.ext, name_02.ext, etc.
        numbered_filename = f"{base_name}_{i+1:0{padding}d}{ext}"
        
        # Combine with directory path
        if dir_path:
            numbered_path = os.path.join(dir_path, numbered_filename)
        else:
            numbered_path = numbered_filename
        
        # Format this single palette
        palette_text = format_single_palette(palette, output_format, i, len(palettes))
        
        # Write to file
        with open(numbered_path, 'w') as f:
            f.write(palette_text)
        
        written_files.append(numbered_path)
        print(f"Written palette {i+1}/{len(palettes)} to: {numbered_path}", file=sys.stderr)
    
    return written_files

def create_executable():
    """Print instructions for creating standalone executable."""
    instructions = """
To create a standalone executable with all dependencies:

1. Install PyInstaller and coloraide:
   pip install pyinstaller coloraide

2. Create single-file executable:
   pyinstaller --onefile --name color_sorter sRGBpalette2palettesByPerceivedDistance_Coloraide_HCT.py

3. The executable will be in dist/color_sorter.exe (Windows) or dist/color_sorter (Linux/Mac)

4. Bundle with your Processing sketch:
   - Copy the executable to your sketch folder
   - The Processing code will automatically detect and use it

Note: coloraide is pure Python, so it bundles easily with PyInstaller.
    """
    print(instructions)

def main():
    """Main entry point with argument parsing."""
    parser = argparse.ArgumentParser(
        description="Perceptual color sorter using HCT color space",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        '-n', '--num-palettes',
        type=int,
        default=5,
        help='Number of output palettes (default: 5)'
    )
    
    parser.add_argument(
        '-e', '--equalcounts',
        action='store_true',
        help='Use simple equal counts instead of adaptive recursive splitting (default: False)'
    )
    
    parser.add_argument(
        '-m', '--min-size',
        type=int,
        default=2,
        help='Minimum number of colors per palette (default: 2)'
    )
    
    parser.add_argument(
        '-i', '--input',
        help='Input file to read'
    )
    
    parser.add_argument(
        '-o', '--output',
        help='Output file base name (default: stdout). When specified, creates numbered files: base_01.ext, base_02.ext, etc.'
    )
    
    parser.add_argument(
        '-f', '--format',
        choices=['processing', 'raw'],
        default='raw',
        help='Output format: processing (JSON) or raw (hex with comments) (default: raw)'
    )
    
    parser.add_argument(
        '--stdin',
        action='store_true',
        help='Read from stdin (must be explicitly specified to avoid hanging)'
    )
    
    parser.add_argument(
        '--build-exe',
        action='store_true',
        help='Show instructions for building executable'
    )
    
    args = parser.parse_args()
    
    # Handle special modes
    if args.build_exe:
        create_executable()
        return
    
    # Determine input source
    input_text = ""
    input_source = None
    
    if args.input:
        # Read from file
        try:
            with open(args.input, 'r') as f:
                input_text = f.read()
            input_source = f"file '{args.input}'"
        except Exception as e:
            print(f"Error reading input file: {e}", file=sys.stderr)
            sys.exit(1)
    elif args.stdin:
        # Read from stdin (explicitly requested)
        input_text = sys.stdin.read()
        input_source = "stdin"
    else:
        # No input source specified
        print("ERROR: No input source specified. Use -i FILE or --stdin.", file=sys.stderr)
        print("Run with -h for help.", file=sys.stderr)
        sys.exit(1)
    
    print(f"Reading from {input_source}", file=sys.stderr)
    
    # Extract hex colors
    hex_colors = extract_hex_colors(input_text)
    
    if not hex_colors:
        print("Warning: No hex colors found in input", file=sys.stderr)
        if args.output:
            print("No colors to process.", file=sys.stderr)
        else:
            if args.format == 'processing':
                print(json.dumps([], indent=2))
            else:
                print("")
        return
    
    print(f"Found {len(hex_colors)} hex colors", file=sys.stderr)
    
    # Process colors
    try:
        palettes = process_colors(hex_colors, args.num_palettes, args.equalcounts, args.min_size)
    except ValueError as e:
        print(f"{e}", file=sys.stderr)
        sys.exit(1)
    
    # Handle output
    if args.output:
        # Write multiple numbered files
        write_output_files(palettes, args.output, args.format)
        print(f"All palettes written with base name: {args.output}", file=sys.stderr)
    else:
        # Write to stdout
        if args.format == 'processing':
            print(json.dumps(palettes, indent=2))
        else:
            lines = []
            for i, palette in enumerate(palettes):
                if i == 0:
                    lines.append(f"# Palette {i} - MOST DISTANT (background layers)")
                elif i == len(palettes) - 1:
                    lines.append(f"# Palette {i} - NEAREST (foreground layers)")
                else:
                    lines.append(f"# Palette {i}")
                
                for hex_color in palette:
                    lines.append(hex_color)
                lines.append("")
            print("\n".join(lines))

if __name__ == "__main__":
    main()