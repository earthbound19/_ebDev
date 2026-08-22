# SEE ALSO
#    tent_pole_sort.sh, an MSYS2 / bash implementation of this algorithm and switches, which
#    handles very long lists efficiently and is well adequate for common use. This script,
#    however, is far more efficient via Python direct interpreter extremely fast functions.

# DESCRIPTION
# Implements a binary bisection tent-pole sorting algorithm with fixed boundary poles.
# Originating use for varied but contiguous-ish Spotify playist sorting by valence
# (happiness). In detail:
# - builds tent-pole placement order using dyadic recursive interval bisection
# - tent Pole 1 (start pole): values are strictly postfixed (appended)
# - tent Pole N (end pole): values are strictly prefixed (prepended)
# - interior poles: alternates append/prepend to create U-shaped sine waves
# - concentrates sine-wave distribution across interior tent poles
#
# Originating usage: a source list of spotify tracks (as copied directly from a
# playlist via the desktop app UI) sorted by descending valence, via tools like:
# - Skiley https://skiley.net/
# - Spicetify extension "SORT PLAY" https://github.com/hoeci/sort-play
# Pass the playlist to this script via clipboard or file (see USAGE), and it will give
# you back the elements in the list arranged with N "tent poles" of highest valence
# tracks at ~regular intervals, interspersed by half-sine-like ~U-shaped valleys.
# The result is a musical journey anchored by a potentially stable series of valence
# peaks and valleys over tracks. But the start and end are high valence.
#
# According to an LLM, this implements:
# "A dyadic bit-reversing permutation script that maps descending values to a hierarchical bisection topology."
#
# Dyadic Recursive Bisection (The Structural Mechanism)
# - "Dyadic" refers to powers of two and fractional halving (1, 1/2, 1/4, 3/4, ...).
#   This describes the geometric process of placing main anchors first and recursively
#   splitting remaining gaps level by level.
#
# Bit-Reversal Permutation (The Algorithmic Implementation)
# - If your array length is a power of 2 (N = 2^k), the sequence of indices generated
#   by dyadic bisection (0, 4, 2, 6, 1, 5, 3, 7) is identical to reversing the binary
#   bits of each index. CS researchers and Fast Fourier Transform (FFT) engineers will
#   recognize this term instantly.
#
# Low-Discrepancy / Quasi-Random Sequence (The Statistical Property)
# - Statisticians use terms like Van der Corput sequence or Sobol sequence to describe
#   distributions where points are added to maximize the distance from all existing points.
#   This algorithm places each new high-value "tent pole" into the largest remaining void.
#
# Hierarchical Waveform Interleaving (The Visual & Functional Output)
# - This describes the multi-resolution result: macro-peaks set the large-scale boundaries,
#   while micro-alternations (append/prepend) construct local U-shaped sine-similar waves
#   across sub-intervals.

# USAGE
# tent_pole_sort.py [-i <source file>] [-n <number of tent poles>] [-v]
#
# OPTIONS:
#   -i, --inputfile             Path to source text file. If omitted, input is read from system clipboard.
#   -n, --number-of-tentpoles   Number of tent poles. If omitted, defaults to 5. Must be at least 2.
#                               may break if N > number of items in source list.
#   -v, --verbose               Print debug info (item count, N, placement order, and destination details).
#
# OUTPUT TARGET FORMAT:
#   - if a source file is provided:         output is written to '[filename]_tentpole_sorted_[N].txt'
#                                           in the same directory.
#   - if the clipboard has a list on it:    clipboard is replaced with script result (output).
#
# EXAMPLES:
#   1. clipboard input, N defaults to 5:
#      python3 /path/to/tent_pole_sort.py
#      -> output: replaces clipboard contents with list reordered by script algorithm
#         with default N = 5 (5 tent poles).
#
#   2. clipboard input, N = 7 (7 tent poles; distributes items into 7 segment buckets):
#      python3 /path/to/tent_pole_sort.py -n 7
#      -> output: replaces clipboard contents with script output of a 7-segment wave
#         (or tent pole and valley U dips) distribution.
#
#   3. file input ('future_bass.txt'), with no N switch: N defaults to 5:
#      python3 /path/to/tent_pole_sort.py -i future_bass.txt
#      -> output: saves to 'future_bass_tentpole_sorted_5.txt'.
#
#   4. file input ('future_bass.txt'), N = 7, with verbose logging:
#      python3 /path/to/tent_pole_sort.py -i future_bass.txt -n 7 -v
#      -> output: saves to 'future_bass_tentpole_sorted_7.txt' and prints debug information to stderr.
# NOTES:
# - using a source list of things sorted ascending (low things first, high things last) will result
#   in an inverse of the tent poles and U-valleys structure: starting low, peaking across inverted
#   valleys, dipping to inverted tent poles, and ending low.
# - feeding output back to input with a different value for N can produce varigated peak / valley
#   results.
# - reversing output line order before feeding it back in can produce further variation


# CODE
import argparse
import os
import sys
from collections import deque

try:
    import pyperclip
    HAS_CLIPBOARD = True
except ImportError:
    HAS_CLIPBOARD = False


# ============================================
# STEP 1: Build tent-pole order using binary bisection
# ============================================

def build_bisection_tent_poles(N):
    """
    Builds tent-pole placement sequence using dyadic binary bisection.
    
    Level 0: Outer boundaries (1, N)
    Level 1: Central midpoint
    Level 2: Midpoints of sub-intervals (1/4, 3/4)
    Level 3+: Recursive bisection of all remaining gaps
    """
    if N <= 0:
        return []
    if N == 1:
        return [1]
    
    order = [1, N]
    visited = {1, N}
    queue = deque([(1, N)])
    
    while queue and len(order) < N:
        left, right = queue.popleft()
        if right - left > 1:
            mid = (left + right) // 2
            if mid not in visited:
                visited.add(mid)
                order.append(mid)
            
            queue.append((left, mid))
            queue.append((mid, right))
            
    # Guarantee full coverage for arbitrary N
    for idx in range(1, N + 1):
        if idx not in visited:
            order.append(idx)
            visited.add(idx)
            
    return order


# ============================================
# STEP 2: Distribute items into tent-pole positions
# ============================================

def sort_tent_pole(items, N=None):
    """
    Maps source items to tent poles with boundary rules:
    - Tent Pole 1 (start pole): strictly postfixed (appended)
    - Tent Pole N (end pole): strictly prefixed (prepended)
    - Interior Poles (2 to N-1): alternates append/prepend for U-shaped waves
    """
    total_items = len(items)
    if total_items == 0:
        return []
    
    if N is None or N <= 0:
        N = total_items
        
    placement_order = build_bisection_tent_poles(N)
    
    if total_items == N:
        # Direct 1-to-1 placement across N poles
        result = [None] * N
        for pos, item in zip(placement_order, items):
            result[pos - 1] = item
        return result
    else:
        # Bucket distribution across N segments
        segments = {seg: [] for seg in range(1, N + 1)}
        phase = {seg: 0 for seg in range(1, N + 1)}
        
        pattern_len = len(placement_order)
        for idx, item in enumerate(items):
            tent_pos = placement_order[idx % pattern_len]
            
            if tent_pos == 1:
                # Start Pole: strictly postfix (append)
                segments[tent_pos].append(item)
            elif tent_pos == N:
                # End Pole: strictly prefix (prepend)
                segments[tent_pos].insert(0, item)
            else:
                # Interior Poles: alternate append / prepend to build U-waves
                if phase[tent_pos] % 2 == 0:
                    segments[tent_pos].append(item)
                else:
                    segments[tent_pos].insert(0, item)
                phase[tent_pos] += 1
            
        # Concatenate segments in tent-pole order (1 to N)
        result = []
        for seg_num in range(1, N + 1):
            result.extend(segments[seg_num])
            
        return result


# ============================================
# STEP 3: File and Clipboard I/O Helpers
# ============================================

def read_file(filename):
    """Reads non-empty lines from a source file."""
    with open(filename, 'r', encoding='utf-8') as f:
        return [line.rstrip('\r\n') for line in f if line.strip()]


def write_file(filename, items):
    """Writes sorted items to the output file."""
    with open(filename, 'w', encoding='utf-8') as f:
        f.write('\n'.join(items) + '\n')


# ============================================
# STEP 4: Command Line Interface & Main Logic
# ============================================

def main():
    parser = argparse.ArgumentParser(
        description="Tent-pole sort a list using recursive binary bisection and fixed boundary poles."
    )
    parser.add_argument(
        '-i', '--inputfile',
        help='Source file path (defaults to clipboard if omitted)'
    )
    parser.add_argument(
        '-n', '--number-of-tentpoles',
        type=int,
        default=5,
        help='Number of tent poles (defaults to 5 if omitted)'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Display verbose debug logging'
    )
    
    args = parser.parse_args()
    
    # Resolve source items from file or system clipboard
    if args.inputfile:
        if not os.path.exists(args.inputfile):
            print(f"ERROR: File not found: {args.inputfile}", file=sys.stderr)
            sys.exit(1)
        items = read_file(args.inputfile)
        use_clipboard = False
        filename = args.inputfile
    else:
        if not HAS_CLIPBOARD:
            print("ERROR: Install pyperclip: pip install pyperclip", file=sys.stderr)
            sys.exit(1)
        clipboard_content = pyperclip.paste()
        items = [line.strip() for line in clipboard_content.splitlines() if line.strip()]
        use_clipboard = True
        filename = "clipboard"
        
    if not items:
        print("ERROR: No items found in input source", file=sys.stderr)
        sys.exit(1)
        
    N = args.number_of_tentpoles if args.number_of_tentpoles else 5
    if N < 2:
        print("ERROR: Number of tent poles must be at least 2", file=sys.stderr)
        sys.exit(1)
        
    if args.verbose:
        print(f"Sorting {len(items)} items across N={N} tent poles", file=sys.stderr)
        tent_poles = build_bisection_tent_poles(N)
        print(f"Bisection placement order: {tent_poles}", file=sys.stderr)
        
    result = sort_tent_pole(items, N)
    
    # Save results to file or clipboard
    if use_clipboard:
        pyperclip.copy('\n'.join(result))
        print(f"DONE. {len(result)} items written to clipboard.", file=sys.stderr)
    else:
        base = os.path.splitext(filename)[0]
        dest = f"{base}_tentpole_sorted_{N}.txt"
        write_file(dest, result)
        print(f"DONE. {len(result)} items written to {dest}", file=sys.stderr)


if __name__ == "__main__":
    main()