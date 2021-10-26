# DESCRIPTION
# Losslessly copies the audio and video streams of input media file $1 to <input_file_name>_tsContainer.ts (an mpeg transport stream).

# DEPENDENCIES
# ffmpeg.

# USAGE
# Run with on parameter, which is the file name of the media file to copy the streams for, e.g.:
#    ffmpegFileToMPEGtransport.sh inputFile.mp4


# CODE
ffmpeg -i $1 -vcodec copy -acodec copy -f mpegts "$1"_tsContainer.ts
# Alternate switch to -f mpegts: -bsf h264_mp4toannexb

# DEVELOPER NOTE
# Previously ffmpegFileToMPEGtransport.bat, functionally identical but run via Windows cmd.