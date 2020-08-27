# DESCRIPTION
# Rips frames from a video file to 7-digit padded number pngs (animation frames).

# USAGE
# Run with one parameter, which is the file name of the input video to rip frames from, for example:
#    ffmpegRipAllFrames.sh inputVideo.mp4
# Result frames are in a folder named <inputVideoFileNameWithoutExtension>.


# CODE
# TO DO
# - add a parameter $2 target dimension to resize to if any (but this is BROKEN at this writing, do not use that parameter!), e.g. nnnnXnnnn or e.g. 320:-1 or -1:800; the latter two calculate and keep an aspect ratio automatically targeting a given X or Y pix dimension. e.g. 320:-1 will target 320x pixels and whatever corresponding Y pixels would keep the aspect, or -1:800 would target 800y pixels and whatever corresponding X pixels will keep the aspect. Is the parameter format this? : -vf scale=$2 Useful reference here: https://trac.ffmpeg.org/wiki/Scaling%20(resizing)%20with%20ffmpeg e.g. constants of iw and ih (image width and image height) can be used; to resize by 1/3 you could do: -vf scale=iw/3:ih/3
# - Maype incorporate these parameters from a now deleted script? : -pix_fmt yuv420p -vcodec rawvideo -acodec adpcm_ima_wav !PARENTDIR!\%%~nF.avi
# Re? : http://superuser.com/questions/347433/how-to-create-an-uncompressed-avi-from-a-series-of-1000s-of-png-images-using-ff
# Re? ffprobe reports my iPhone .mov sources use this pixel format (yuv420p), and these avis load into Sony Vegas without any problems.

# Command updated thanks to a post here (it wouldn't accept the -image2 parameter anymore. ?) : http://gutsup.tumblr.com/post/7337621736/converting-video-to-image-sequences-with-ffmpeg
fileNameNoExt=${1%.*}
mkdir $fileNameNoExt
ffmpeg -i $1 "$fileNameNoExt"/%7d.png