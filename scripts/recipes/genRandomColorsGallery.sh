# DESCRIPTION
# Creates a markdown image gallery of randomly generated color palettes. Not platform-neutral (uses IrfanView).

# USAGE
# Run without any parameter:
#    genRandomColorsGallery.sh


# CODE
# TO DO
# - Parameterize number of images to make.
# - Make a directory named after the date and a random string and cd into it before all this other code.
NrandomHexColorSchemes.sh 6
	# Option that isn't working as I would hope at this writing; commenting out:
	# allhexplt2ppm.sh
	# imgs2imgsnn.sh ppm png 540
	# rm *.ppm
renderAllHexPalettes.sh


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