# DESCRIPTION
# Retrieves and reads out loud from the Gibberish Artist Statement Dispenser https://earthbound.io/data/gibberish-artist-statements/index.php (URL subject to change), via the Mac "say" command/utility. MacOS only.

# USAGE
# Run without any parameter:
#    speakArtGibberish.sh


# CODE
curl https://earthbound.io/data/gibberish-artist-statements/index.php?gib=speakartgibberishscript | say