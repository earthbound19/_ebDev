mapfile -t wordList < /cygdrive/c/_devtools/scripts/lit/gibberish/python-Backus-Naur-poetry-generator/resources/ACT_study_words.txt

for word in "${wordList[@]}"
do
	"/cygdrive/c/Program Files (x86)/WordNet/2.1/bin/wn.exe" "$word" -over >> ACT_study_words_corrected_definitions.txt
	echo ---------------- >> ACT_study_words_corrected_definitions.txt
done