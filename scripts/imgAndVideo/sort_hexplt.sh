# DESCRIPTION
# Overwrites a .hexplt file (pass it to the script as $1) with a hex-sorted copy of itself.

# USAGE
# sort_hexplt.sh a_hexplt_file.hexplt


# CODE
# Re: https://unix.stackexchange.com/a/360716/110338
awk '{printf("%050s\t%s\n", toupper($0), $0)}' $1 | LC_COLLATE=C sort -k1,1 | cut -f2 > tmp_6kDuyWZADTuQ.txt

mv tmp_6kDuyWZADTuQ.txt $1
