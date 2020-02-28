# DESCRIPTION
# Prints N variants of constructed random character sets (hard-coded but hackable: block
# characters), at X characters accross and Y lines down each. Prints to either terminal or
# files; hack the global variable SAVE_TO_RND_FILENAMES to alter that; hack the other globals
# also for whatever other purposes you might have.

# USAGE
# - With this script in your path, invoke it with Python:
# python randomNsetChars.py
# - NOTE that the hard-coded defaults create 1,000 rnd character set variations saved to
# text files in the directory you run this script from. So be prepared, ha, for a lot of noise.
# - Also, hack the global variables (under the GLOBALS comment) for your purposes if you wish.


# CODE
import random
from time import sleep

# GLOBALS:
# Seeds rando number generator via current time:
random.seed(None, 2)
# OR you can seed with a specific number, e.g.:
# random.seed(5, 2)
# -- and it will always produce the same output, in that case.
CHARSET = "▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟■"
CHOOSE_RND_SUBSET = True
SAVE_TO_RND_FILENAMES = True
# REFERENCE: 1,000 ms = 1 second:
VARIANTS_TO_GENERATE = 1000
CHARS_PER_LINE = 60
LINES_PER_GENERATED_SET = 16    # Also try e.g. 2
# The following is note used in the script if SAVE_TO_RND_FILENAMES is True:
WAIT_BETWEEN_LINES_MS = 142     # some oft-used choices: 82, 142

# DERIVATIVE VALUES SET FROM GLOBALS:
SLEEP_TIME = WAIT_BETWEEN_LINES_MS * 0.001

# Function intended use: if a controlling boolean is true, gets and
# returns a unique subset of characters from string CHARSET_STRING_PARAM;
# otherwise returns the string unmodified:  
def get_charset_subset(CHARSET_STRING_PARAM):
    if (CHOOSE_RND_SUBSET == True):
        subset_select_percent = random.uniform(0.04,0.31)
        loc_operative_charset_len = len(CHARSET_STRING_PARAM)
        num_chars_in_subset = int(loc_operative_charset_len * subset_select_percent)
        # If that ends up being less than two, set it to two:
        if (num_chars_in_subset < 2):
            num_chars_in_subset = 2
        counter = 0
        tmp_string = ""
        while counter < num_chars_in_subset:
            chosen_char = CHARSET[random.randrange(0, loc_operative_charset_len)]
            if chosen_char not in tmp_string:
                tmp_string += chosen_char
                counter += 1
        return tmp_string
    else:
        return CHARSET_STRING_PARAM

def get_rnd_save_file_name():
    file_name_char_space = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789"
    char_space_len = len(file_name_char_space)
    file_name_str = ""
    for i in range(19):
        file_name_str += file_name_char_space[random.randrange(0, char_space_len)]
    return file_name_str

n_set_outputs_counter = 0
digits_to_pad_file_numbers_to = len(str(VARIANTS_TO_GENERATE))
while n_set_outputs_counter < VARIANTS_TO_GENERATE:
    n_set_outputs_counter += 1
    # To collect character noise block sample for saving to file (not only for
    # printing to screen) ; there's a trivial performance penalty here if we don't use this str:
    super_string = ""
    operative_charset = get_charset_subset(CHARSET)
    operative_charset_len = len(operative_charset)
    lines_counter = 0
    while lines_counter < LINES_PER_GENERATED_SET:
        rnd_string = ""
        char_counter = 0
        while char_counter < CHARS_PER_LINE:
            rnd_string += operative_charset[random.randrange(0, operative_charset_len)]
            char_counter += 1
        # Only print rnd block chars to terminal if we're not saving files; otherwise,
        # collect them in super_string:
        if (SAVE_TO_RND_FILENAMES == False):
            print(rnd_string)
            sleep(SLEEP_TIME)
        else:
            super_string += rnd_string + "\n"
        lines_counter += 1
    # If a boolean says to save the collected rnd chars to a file, do so:
    if (SAVE_TO_RND_FILENAMES == True):
        save_file_name = get_rnd_save_file_name()
        # get number padded to number of zeros to align numbers to VARIANTS_TO_GENERATE,
        # for file name; therefore convert n_set_outputs_counter to string for zfill function:
        str_n_set_outputs_counter = str(n_set_outputs_counter)
        file_number_zero_padded = str_n_set_outputs_counter.zfill(digits_to_pad_file_numbers_to)
        file = open(file_number_zero_padded + "__" + save_file_name + '.txt', "w")
        file.write(super_string)
        file.close()
    # print("DONE creating variant", n_set_outputs_counter, "in run.")

