# DESCRIPTION: Uses the split command to divide a file into smaller segments which may be recombined to form the original file again.

# USAGE: invoke this script with two parameters, the first being the text file to split, the second being how many kilobyte chunks to split it into. Recombine the files by placing them in their own directory and running the command: cat .*

# NOTES: You can also simply invoke the split tool (with these parameters) from any 'nix or other shell that has the split program in it's path (and not use this script at all--this script functions in fact more like reference than a script to use). The -C switch tells split to put at most n bytes of *lines of a text file* (it splits by lines) in each output chunk. Without the -C switch it operates in binary mode; in fact it seems to deliberately refuse to split text files without the -C switch.

split ./$1 -C $2K