# get all lines in B that are not in A, and write them to B:
lines=($(filterExcludedWords.sh A.txt B.txt))
# before overwriting B, get all removed lines and write them to removed_from_B:
lines2=($(filterIncludedWords.sh A.txt B.txt))
printf '%s\n' "${lines[@]}" | tr -d '\15\32' > B.txt
printf '%s\n' "${lines2[@]}" > removed_from_B.txt

echo "DONE. Everything that is in both A and B was removed from B."
echo "Also, everything removed from B was logged in removed_from_B.txt."