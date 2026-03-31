# DESCRIPTION
# Prints random characters from a random character set A, then B, then A, in an infinite loop. See also `randomNsetCharsAlt2py`. (This prints more characters per line than that.)

# DEPENDENCIES
# Python 3.8 (or maybe any 3.x version) with random and time modules installed. Moreover, python may need to be compiled with UCS2 or UCS4 support (larger text code pages support).

# USAGE
# Run from a python interpreter:
#    python /path/to_this_script/randomNsetCharsAlt.py

# CODE
import random
import sys
import time
sys.stdout.reconfigure(encoding='utf-8')

# GLOBALS
# Seeds rando number generator via current time:
random.seed(None, 2)
# OR you can seed with a specific number, e.g.:
# random.seed(5, 2)
# -- and it will always produce the same output, in that case.

# define possible random character sets:
CHARSETS = [
"▀▁▃▅▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟■",           # block characters set
"┈┉┊┋┌└├┤┬┴┼╌╍╎╭╮╯╰╱╲╳╴╵╶╷",                # box drawing subset
"▲△◆◇○◌◍◎●◜◝◞◟◠◡◢◣◤◥◸◹◺◿◻◼",        # geometric shapes subset
"∧∨∩∪∴∵∶∷∸∹∺⊂⊃⊏⊐⊓⊔⊢⊣⋮⋯⋰⋱",                 # math operators subset
"◈⟐⟢ːˑ∺≋≎≑≣⊪⊹☱☰☲☳☴☵☶☷፨჻܀",          # Apple emoji subset
"─│┌┐└┘├┤┬┴┼╭╮╯╰╱╲╳▂▃▄▌▍▎▏▒▕▖▗▘▚▝○●◤◥♦",    # Commodore 64 font/drawing glyphs set--which, it happens, combines characters from some of the others interestingly.
"▔▀▆▄▂▌▐█▊▎░▒▓▖▗▘▙▚▛▜▝▞▟",                      # block characters subset
]


while True:
# randomly choose one of the character sets:
    CHARSET = random.choice(CHARSETS)
    char_counter = 0
    rnd_string = ''
    while char_counter < 16:
        rnd_string += CHARSET[random.randrange(0, len(CHARSET))]
        char_counter += 1
    char_counter = 0
    # CORE_CHARSET = CHARSETS[0]
    CORE_CHARSET = random.choice(CHARSETS)
    while char_counter < 40:
        rnd_string += CORE_CHARSET[random.randrange(0, len(CORE_CHARSET))]
        char_counter += 1
    char_counter = 0
    while char_counter < 16:
        rnd_string += CHARSET[random.randrange(0, len(CHARSET))]
        char_counter += 1
    print(rnd_string)
    time.sleep(0.8)