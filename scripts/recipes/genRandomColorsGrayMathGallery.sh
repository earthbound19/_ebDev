# DESCRIPTION
# Creates a markdown image gallery of randomly generated color palettes using "gray math" (where the sum of colors by additive color mixing will make a shade of white). Not platform-neutral (uses irfanview).

# USAGE
#    genRandomColorsGrayMathGallery.sh


# CODE
# TO DO
# parameterize number of images to make.
pythonScriptPath=`whereis NrandomHexColorSchemesGrayMath.py | sed 's/.* \(.*\/NrandomHexColorSchemesGrayMath.py\).*/\1/g'`
python \"$pythonScriptPath\"
# TO DO: make a directory named after the date and a random string and cd into it, then:
allhexplt2ppm.sh
imgs2imgsnn.sh ppm png 540
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