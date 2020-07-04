# DESCRIPTION
# Wrapper that renders any text within quote marks to a randomly named audio file.

# USAGE
# Invoke this script with one paramater, being any text to render to a .wav file (text encased in "quote marks"); e.g.:
#  ./balabokaTextToSpeechWav.sh "blarpnoi hoi hoi"

# DEPENDENCIES
# Balaboka.exe / (windows text-to-speech engine tool) and Cygwin or other 'nix environment


# CODE
textSay=$1
fileName=$1
		# OPTIONAL alternate for file names and random text; if you uncomment the next three lines, comment out the previous two:
		# export LC_CTYPE=C
		# textSay=`cat /dev/urandom | tr -dc 'a-z ' | head -c 18`
		# fileName=$textSay
./balcon -t "$textSay" -w "$fileName"".wav"
cygstart "./""$fileName"".wav"