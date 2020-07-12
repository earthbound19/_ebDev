# DESCRIPTION
# Uses the split command to divide a file into smaller segments (dividing on line breaks) which may be recombined to form the original file again.

# USAGE
# Invoke with these parameters:
# - $1 the file name of the text file to split
# - $2 size, in kilobytes, of chunks to split the file into
# Example command that will split a file named aHugoriousTextFile.txt into 4-kilobyte chunks:
#  splitTextFile.sh aHugoriousTextFile.txt 4
# NOTES
# - You can recombine the files by placing them in their own directory and running the command: cat .*
# - You can also simply invoke the split tool (with these parameters) from any 'nix or other shell that has the split program in it's path (and not use this script at all--this script functions in fact more like reference than a script to use). The -C switch tells split to put at most n bytes of *lines of a text file* (it splits by lines) in each output chunk. Without the -C switch it operates in binary mode; in fact it seems to deliberately refuse to split text files without the -C switch.


# CODE
split ./$1 -C $2K