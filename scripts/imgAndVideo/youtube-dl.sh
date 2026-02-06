# DESCRIPTION
# Wrapper for youtube-dl which passes preferred CLI options to program before download URL $1

# USAGE
# Run this script with one parameter, which is the URL to a video to download:
#    youtube-dl.sh URL-to-video
# OR TRY yt-dlp (e.g. yt-dlp -x 'URL-to-media'` to extract audio), which may work better and have more features.


# CODE
additionalParams="--audio-quality 0"
youtube-dl --no-playlist --skip-unavailable-fragments --no-overwrites --write-description --all-formats --youtube-skip-dash-manifest --merge-output-format mp4 --extract-audio --audio-format best --recode-video mp4 --keep-video $additionalParams $1
