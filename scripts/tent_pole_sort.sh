# SEE ALSO
#    tent_pole_sort.py, a Python implementation of this algorithm and switches, which
#    handles extremely long source lists more efficiently than this bash script.

# DESCRIPTION
# Implements a binary bisection tent-pole sorting algorithm with fixed boundary poles.
# Originating use for varied but contiguous-ish Spotify playlist sorting by valence
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

# ============================================
# USAGE
# ============================================
#
# tent_pole_sort.sh [-i <source file>] [-n <number of tent poles>] [-v]
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
#      ./tent_pole_sort.sh
#      -> output: replaces clipboard contents with list reordered by script algorithm
#         with default N = 5 (5 tent poles).
#
#   2. clipboard input, N = 7 (7 tent poles; distributes items into 7 segment buckets):
#      ./tent_pole_sort.sh -n 7
#      -> output: replaces clipboard contents with script output of a 7-segment wave
#         (or tent pole and valley U dips) distribution.
#
#   3. file input ('future_bass.txt'), with no N switch: N defaults to 5:
#      ./tent_pole_sort.sh -i future_bass.txt
#      -> output: saves to 'future_bass_tentpole_sorted_5.txt'.
#
#   4. file input ('future_bass.txt'), N = 7, with verbose logging:
#      ./tent_pole_sort.sh -i future_bass.txt -n 7 -v
#      -> output: saves to 'future_bass_tentpole_sorted_7.txt' and prints debug information to stderr.
#
# NOTES:
# - using a source list of things sorted ascending (low things first, high things last) will result
#   in an inverse of the tent poles and U-valleys structure: starting low, peaking across inverted
#   valleys, dipping to inverted tent poles, and ending low.
# - feeding output back to input with a different value for N can produce varigated peak / valley
#   results.
# - reversing output line order before feeding it back in can produce further variation


# CODE
# ============================================
set -u

# Default values
N=5
INPUT_FILE=""
VERBOSE=0

# ============================================
# Help / Usage Function
# ============================================

usage() {
    cat >&2 <<EOF
Usage:
  tent_pole_sort.sh [-n N] [-i INPUT_FILE]
  tent_pole_sort.sh [-n N] [INPUT_FILE]

Options:
  -n N, --number-of-tentpoles N
      Number of tent poles. Defaults to 5.

  -i FILE, --inputfile FILE
      Read source list from FILE instead of the clipboard.

  -v, --verbose
      Print debug information to stderr.

  -h, --help
      Show this help.

If no input file is specified, the source list is read from the clipboard.
EOF
}

# ============================================
# Parse Command Line Arguments
# ============================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--number-of-tentpoles)
            if [[ $# -lt 2 ]]; then
                echo "ERROR: $1 requires a number." >&2
                exit 1
            fi
            N="$2"
            shift 2
            ;;

        -n*)
            N="${1#-n}"
            shift
            ;;

        -i|--inputfile)
            if [[ $# -lt 2 ]]; then
                echo "ERROR: $1 requires a filename." >&2
                exit 1
            fi
            INPUT_FILE="$2"
            shift 2
            ;;

        -v|--verbose)
            VERBOSE=1
            shift
            ;;

        -h|--help)
            usage
            exit 0
            ;;

        -*)
            echo "ERROR: Unknown option: $1" >&2
            usage
            exit 1
            ;;

        *)
            if [[ -n "$INPUT_FILE" ]]; then
                echo "ERROR: Multiple input files specified." >&2
                exit 1
            fi
            INPUT_FILE="$1"
            shift
            ;;
    esac
done

# Validate N
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Number of tent poles must be an integer." >&2
    exit 1
fi

if (( N < 2 )); then
    echo "ERROR: Number of tent poles must be at least 2." >&2
    exit 1
fi

# ============================================
# Read Source Items (File or Clipboard)
# ============================================

source_items=()

if [[ -n "$INPUT_FILE" ]]; then

    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "ERROR: File not found: $INPUT_FILE" >&2
        exit 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ -n "${line//[[:space:]]/}" ]]; then
            source_items+=("$line")
        fi
    done < "$INPUT_FILE"

else

    # Try various clipboard methods
    if command -v clip.exe >/dev/null 2>&1; then
        clipboard_contents="$(powershell.exe -NoProfile -Command 'Get-Clipboard' 2>/dev/null || true)"
    elif command -v powershell.exe >/dev/null 2>&1; then
        clipboard_contents="$(powershell.exe -NoProfile -Command 'Get-Clipboard' 2>/dev/null || true)"
    elif command -v xclip >/dev/null 2>&1; then
        clipboard_contents="$(xclip -selection clipboard -o 2>/dev/null || true)"
    elif command -v xsel >/dev/null 2>&1; then
        clipboard_contents="$(xsel --clipboard --output 2>/dev/null || true)"
    else
        echo "ERROR: Could not find a supported clipboard command." >&2
        exit 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ -n "${line//[[:space:]]/}" ]]; then
            source_items+=("$line")
        fi
    done <<< "$clipboard_contents"
fi

if (( ${#source_items[@]} == 0 )); then
    echo "ERROR: No items found in input source." >&2
    exit 1
fi

# ============================================
# STEP 1: Build Bisection Placement Order
# ============================================
#
# This is a direct Bash translation of Gemini's Python algorithm:
#
#     order = [1, N]
#     queue = [(1, N)]
#
# Then repeatedly:
#
#     midpoint = (left + right) // 2
#
# and queue the two resulting intervals.
#
# Level 0: Outer boundaries (1, N)
# Level 1: Central midpoint
# Level 2: Midpoints of sub-intervals (1/4, 3/4)
# Level 3+: Recursive bisection of all remaining gaps
# ============================================

placement_order=()
placement_order+=("1")

if (( N > 1 )); then
    placement_order+=("$N")
fi

# Bash doesn't have a native tuple queue, so maintain two parallel arrays.
queue_left=()
queue_right=()

queue_left+=("1")
queue_right+=("$N")

queue_index=0

while (( queue_index < ${#queue_left[@]} && ${#placement_order[@]} < N )); do

    left="${queue_left[$queue_index]}"
    right="${queue_right[$queue_index]}"

    ((queue_index++))

    if (( right - left > 1 )); then

        midpoint=$(( (left + right) / 2 ))

        placement_order+=("$midpoint")

        queue_left+=("$left")
        queue_right+=("$midpoint")

        queue_left+=("$midpoint")
        queue_right+=("$right")
    fi
done

if (( VERBOSE )); then
    printf 'Sorting %d items across N=%d tent poles\n' \
        "${#source_items[@]}" "$N" >&2

    printf 'Bisection placement order:' >&2

    for pole in "${placement_order[@]}"; do
        printf ' %s' "$pole" >&2
    done

    printf '\n' >&2
fi

# ============================================
# STEP 2: Distribute Items into Tent-Pole Positions
# ============================================
#
# Dynamically create N segment buckets.
#
# IMPORTANT:
# These are NOT dynamically named Bash arrays.
#
# The associative array uses the pole number as its key:
#
#     segments[1]
#     segments[2]
#     ...
#     segments[N]
#
# Each value is a newline-separated list.
#
# This deliberately avoids indirect array expansion such as:
#
#     "${segment_2[@]}"
#
# which was the source of the literal "segment_2[@]" output.
#
# Boundary Rules:
# - Pole 1 (start pole): strictly postfixed (appended)
# - Pole N (end pole): strictly prefixed (prepended)
# - Interior Poles (2 to N-1): alternates append/prepend for U-shaped waves
# ============================================

declare -A segments
declare -A phase

for ((pole = 1; pole <= N; pole++)); do
    segments[$pole]=""
    phase[$pole]=0
done

placement_count="${#placement_order[@]}"

for ((index = 0; index < ${#source_items[@]}; index++)); do

    item="${source_items[$index]}"

    placement_index=$(( index % placement_count ))
    tent_position="${placement_order[$placement_index]}"

    if (( tent_position == 1 )); then

        # Start pole: strictly append.
        if [[ -z "${segments[$tent_position]}" ]]; then
            segments[$tent_position]="$item"
        else
            segments[$tent_position]+=$'\n'"$item"
        fi

    elif (( tent_position == N )); then

        # End pole: strictly prepend.
        if [[ -z "${segments[$tent_position]}" ]]; then
            segments[$tent_position]="$item"
        else
            segments[$tent_position]="$item"$'\n'"${segments[$tent_position]}"
        fi

    else

        # Interior pole: alternate append/prepend.
        if (( phase[$tent_position] % 2 == 0 )); then

            if [[ -z "${segments[$tent_position]}" ]]; then
                segments[$tent_position]="$item"
            else
                segments[$tent_position]+=$'\n'"$item"
            fi

        else

            if [[ -z "${segments[$tent_position]}" ]]; then
                segments[$tent_position]="$item"
            else
                segments[$tent_position]="$item"$'\n'"${segments[$tent_position]}"
            fi
        fi

        phase[$tent_position]=$(( phase[$tent_position] + 1 ))
    fi
done

# ============================================
# STEP 3: Concatenate Segments in Tent-Pole Order
# ============================================

output_lines=()

for ((pole = 1; pole <= N; pole++)); do

    if [[ -n "${segments[$pole]}" ]]; then

        while IFS= read -r line; do
            output_lines+=("$line")
        done <<< "${segments[$pole]}"

    fi
done

# ============================================
# STEP 4: Write Output (File or Clipboard)
# ============================================

if [[ -n "$INPUT_FILE" ]]; then

    base="${INPUT_FILE%.*}"

    if [[ "$base" == "$INPUT_FILE" ]]; then
        output_file="${INPUT_FILE}_tentpole_sorted_${N}.txt"
    else
        output_file="${base}_tentpole_sorted_${N}.txt"
    fi

    printf '%s\n' "${output_lines[@]}" > "$output_file"

    echo "DONE. ${#output_lines[@]} items written to $output_file" >&2

else

    output_text=""

    for line in "${output_lines[@]}"; do
        if [[ -n "$output_text" ]]; then
            output_text+=$'\n'
        fi
        output_text+="$line"
    done

    if command -v clip.exe >/dev/null 2>&1; then
        printf '%s' "$output_text" | clip.exe
    elif command -v powershell.exe >/dev/null 2>&1; then
        printf '%s' "$output_text" | powershell.exe -NoProfile -Command \
            '$input | Set-Clipboard'
    elif command -v xclip >/dev/null 2>&1; then
        printf '%s' "$output_text" | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        printf '%s' "$output_text" | xsel --clipboard --input
    else
        echo "ERROR: Could not find a supported clipboard command." >&2
        exit 1
    fi

    echo "DONE. ${#output_lines[@]} items written to clipboard." >&2
fi