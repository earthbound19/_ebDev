# DESCRIPTION
# Retrieves and reads out loud from the Gibberish Artist Statement Dispenser https://earthbound.io/data/gibberish-artist-statements/index.php (URL subject to change), via the Mac "say" command/utility on MacOS, or Balaboka on Windows (MSYS2).

# USAGE
# Run without any parameter:
#    speakArtGibberish.sh


# CODE
# get an a gibberish artist statement via curl and store it in a variable, $gib:
gib=$(curl https://earthbound.io/data/gibberish-artist-statements/index.php?gib=speakartgibberishscript)

# detect platform from environment variable; re: https://stackoverflow.com/a/8597411
if [[ "$OSTYPE" == "darwin"* ]]; then
	say "$gib"
elif [[ "$OSTYPE" == "msys" ]]; then
	balcon -t "$gib"
else
	echo "$gib"
	echo "--"
    echo "Platform unknown (apparently not Windows or MacOS). Please check the value of $OSTYPE and hack this script to use a text to speech program for your platform."
fi
