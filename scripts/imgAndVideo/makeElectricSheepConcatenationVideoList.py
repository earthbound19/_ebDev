# Creates a file called 'sheep_concatenation_list.txt' that can be used with ffmpeg to concatenate a series of Electric Sheep videos. The concatenation list:
# - Uses all .mp4 files in the current directory, or a specified number of them, in random order.
# - Matches the genome ID at the end of a one video to the genome ID at the start of the next video, to make seamless transitions, wherever possible. If no such match is found, a random video is chosen for the next video.
# - The output file is named sheep_concatenation_list_<datetime>.txt, where <datetime> is the date and time the script was run, in format YYYY-MM-DD__HH-MM-SS.
# - .mp4 files may be reused to make a matching transition.
# See also concatVideos.sh for a script that can use the output of this script to create a concatenated video file.

# DEPENDENCIES
#    Python 3.x (and not an earlier version?)
#    This script should be run in a directory containing .mp4 files with names in the expected format: <generation number>=<first genome ID>=<middle genome ID>=<last genome ID>.mp4

# USAGE
# Call the script with the following switches:
#    sys.argv[1] OPTIONAL. An integer (e.g. 9), which is the number of files to use in the concatenation list. If not provided, default is to use all .mp4 files in the current directory.
# For example to to use all .mp4 files in the current directory:
#    python makeElectricSheepConcatenationVideoList.py
# Or to use only 9 .mp4 files in the current directory:
#    python makeElectricSheepConcatenationVideoList.py 9


# CODE
import os
import sys
import random

# if it exists, assign sys.argv[1] to a variable called n_files_to_use; otherwise, set n_files_to_use to None
n_files_to_use = None
if len(sys.argv) > 1:
    # try to convert sys.argv[1] to an integer; if it fails, exit with an error message
    try:
        n_files_to_use = int(sys.argv[1])
    except ValueError:
        print("Error: sys.argv[1], if provided, must be an integer.")
        sys.exit(1)

# get a list of all .mp4 files in the current directory:
files = [f for f in os.listdir('.') if f.endswith('.mp4')]

# if no mp4 files were found, exit with an error message:
if not files:
    print("Error: No .mp4 files were found in the current directory.")
    sys.exit(2)

# randomize the order of that list:
random.shuffle(files)

# if n_files_to_use is not None, reduce the list to the first n_files_to_use elements:
if n_files_to_use is not None:
    files = files[:n_files_to_use]

# The file name structure expected for "sheep" this makes a concatenation list of is:
# <generation number>=<first genome ID>=<middle genome ID>=<last genome ID>.mp4
# build a file concatenation list for ffmpeg such that:
# - every time we add a file from the files[] list to the concatenation list, we remove it from files[]
# - the concatenation list is written to a file called 'sheep_concatenation_list.txt'
# - the concatenation list is in the format required by ffmpeg: `file 'filename.mp4'`
# - where possible, last_genome_ID from a file name matches first_genome_ID of the next file name
# - also, before the loop, pick the first file in the list as the starting point.
next_file = files.pop(0)
# initialize a set of used files (those that have been added to the concatenation list), to potentially reuse any of them later if needed
used_files = set()

# name the output file 'sheep_concatenation_list_<datetime>.txt'; obtain datetime in format YYYYMMDD_HHMMSS
import datetime
now = datetime.datetime.now()
datetime_string = now.strftime("%Y-%m-%d__%H-%M-%S")
concatenation_list_filename = f'sheep_concatenation_list_{datetime_string}.txt'

# set a reused filename variable to None; this may be set to a filename later if we reuse a used file
reused_filename = None
previous_filename = None
with open(concatenation_list_filename, 'w') as concat_file:
    while files:
        # write the next file name to the concatenation list
        concat_file.write(f"file '{next_file}'\n")
        # extract the last genome ID from that file name
        last_genome_id = next_file.split('=')[-1].split('.')[0]
        # print(last_genome_id + " is the last genome ID in file " + next_file)
        # look through the files list for a file that starts with last_genome_id, and if found, set next_file to that file.
        previous_filename = next_file
        next_file = None
        for f in files:
            # NOTE we split on [1] and NOT [0], as [0] is the generation number and [1] is the first genome ID (see above)
            if f.split('=')[1] == last_genome_id:
                next_file = f
                files.remove(f)
                used_files.add(f)
                reused_filename = None    # see comments below for explanation of reused_filename
                break
            # if no file matching that criterion is found, search used_files for a file that starts with last_genome_id, and if found, set next_file to that file, IF we didn't just reuse a file name (if reused_filename is set to None). This is to prevent an infinite loop of reusing the same file.
            if not next_file and reused_filename == None and used_files:   # that last can't hurt, dunno??
                for f in used_files:
                    if f.split('=')[1] == last_genome_id:
                        if f == previous_filename:  # don't reuse the same file twice in a row
                            continue                # meaning, we continue to next iteration of inner for loop; the next_file assignment on the next line is skipped
                        next_file = f
                        reused_filename = f
                        break
        # if next_file has no value (none was found), pick a random file from files[] for it
        if next_file == None:
            next_file = files.pop(0)
            # add the used file to the used_files list
            used_files.add(next_file)

print(f'\nDONE. New list file name is {concatenation_list_filename}. You may use e.g. this script and command to make an animation from them:\n\n    concatVideos.sh mp4 {concatenation_list_filename}\n')