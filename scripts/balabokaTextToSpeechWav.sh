# DESCRIPTION
# Wrapper that renders any text within quote marks to a randomly named audio file. Windows-only. For MacOS, you can run this:
#    say "blorf blefl horple"
# OR
#    cat inputFile.txt | say
# OR (better yet) :
#    curl https://earthbound.io/data/gibberish-artist-statements/index.php?gib=florf | say

# DEPENDENCIES
# Balaboka CLI (balcon.exe) / (windows text-to-speech engine tool) installed and in your PATH and MSYS2 or other 'nix environment on Windows.

# USAGE
# Run this script with one parameter, which is any text to render to a .wav file (text encased in "quote marks"); e.g.:
#    balabokaTextToSpeechWav.sh "blarpnoi hoi hoi"
# SUGGESTION
# These commands don't use this script, they are reference:
# Grab a fake artist statement from the "Gibberish Artist Statement Dispenser" and say it out loud:
#    curl https://earthbound.io/data/gibberish-artist-statements/index.php?gib=florf > gib.txt
#    ./balcon -f gib.txt


# CODE
# TO DO
# - Examine http://espeak.sourceforge.net/

textSay=$1; fileName=$1
balcon -t "$textSay" -w "$fileName"".wav"