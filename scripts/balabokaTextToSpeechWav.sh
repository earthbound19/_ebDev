# DESCRIPTION
# Wrapper that renders any text within quote marks to a .wav audio file, with the text incorporated in the file name, and then starts the .wav file with the default player or handler. Windows-only. For MacOS, you can run this:
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

if [ ! "$1" ]; then printf "\nNo parameter \$1 (source text file to convert to wav sound file) passed to script. Exit."; exit 1; fi

textSay=$(cat $1 | tr '\n' ' ');
# replace any terminal-unfriendly characters in the source string with underscores to help form the render target file name:
renderTargetFileNamePart=$(echo $textSay | tr \`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \. _)
# truncate that to 32 characters max.:
renderTargetFileNamePart=$(cut -c -32 <<< $renderTargetFileNamePart)
# get a random string to append to that (will avoid any file name part that already exists in the current directory) :
rndString=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 11)
# -- and append it:
renderTargetFileName="$renderTargetFileNamePart"_"$rndString".wav
balcon -t "$textSay" -s -3 -w "$renderTargetFileName"
start "$renderTargetFileName"