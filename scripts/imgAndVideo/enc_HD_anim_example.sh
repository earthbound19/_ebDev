cd vars_ppm
img2imgNearestNeigbor_all.sh ppm png 1920 1080
mkdir ../png
mv *.png ../png
cd ../png
allRandomFileNames.sh 8 png
renumberFiles.sh png
ffmpegAnim.sh 24 29.97 13 png
# rm *.png
mv _out.mp4 "../2016-10-07_randomColorStripes_anim.mp4"