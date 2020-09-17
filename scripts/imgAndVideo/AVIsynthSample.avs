# Uncomment and edit the following lines to control AVFS
# features.

#  Change default read-ahead frame count. Set to 0 to disable
#  read-ahead. Read-ahead facilitates better multi
#  core/CPU/system utilization since filters are able
#  to run asynchronously with the consuming application.
# AVFS_ReadAheadFrameCount=35

#  Do not interleave audio and video data per-frame. This may
#  improve performance with some encoders/players.
# AVFS_AVI_NoInterleave=false

#  Limit size of each RIFF segment in AVI file to 1GB instead
#  of 4GB. Improves compatibility with some applications at the
#  cost of slower initialization with other applications.
# AVFS_AVI_SmallSegments=false

#  Override fourcc code for video data. This has no effect
#  on the format of the video data in the emitted file, but
#  may be useful for applications that recognize the format
#  when it has a different fourcc code.
# AVFS_AVI_VidFcc="yuvs"

ColorBars()
Trim(0,500)
ConvertAudioTo16bit()
AssumeSampleRate(44100)
ConvertToYv12()
