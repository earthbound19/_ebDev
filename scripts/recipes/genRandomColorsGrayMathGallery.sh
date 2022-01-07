# DESCRIPTION
# Creates a markdown image gallery of randomly generated color palettes using "gray math" (where the sum of colors by additive color mixing will make a shade of white). At this writing and possibly forever, the palette rending script (which this calls) that calls another script is not platform-neutral (uses irfanview).

# USAGE
#    genRandomColorsGrayMathGallery.sh


# CODE
# TO DO
# parameterize number of images to make.
pythonScriptPath=$(getFullPathToFile.sh NrandomHexColorSchemesGrayMath.py)

python $pythonScriptPath

allhexplt2ppm.sh
imgs2imgsNN.sh ppm png 540 270
rm *.ppm

echo ~~~~
read -r -p "To delete .hexplt files which resulted in color palette images you don't like, look through all the resultant .png images in this directory and delete the ones you don't like, then enter Y to continue. Otherwise enter N to stop." response
case $response in
    [yY]) 
        echo Dokee-okee! Working . . .;
		pruneByUnmatchedExtension.sh hexplt png
		palettesMarkdownGallery.sh
        ;;
    *)
        echo D\'oh! Terminating script.; exit;
        ;;
esac

palettesMarkdownGallery.sh