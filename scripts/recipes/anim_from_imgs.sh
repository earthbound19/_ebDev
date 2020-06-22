mkNumberedLinks.sh tif
cd _temp_numbered
allimg2img.sh tif png
ffmpegAnim.sh 60 60 17 png
mv *.mp4 ..
cd ..
rm -rf _temp_numbered