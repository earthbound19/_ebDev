# get all lines that are in both A and B, and write them to B:
lines=($(filterIncludedWords.sh A.txt B.txt))
# before writing that to B, get all lines that will be removed from B:
lines2=($(filterExcludedWords.sh A.txt B.txt))
printf '%s\n' "${lines[@]}" | tr -d '\15\32' > B.txt
printf '%s\n' "${lines2[@]}" | tr -d '\15\32' > removed_from_B.txt

echo "DONE. Everything that was not in both A and B was removed from B."
echo "Also, everything removed from B was logged in removed_from_B.txt."