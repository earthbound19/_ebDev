# DESCRIPTION
# Converts a fountain format plain text file screenplay into a formatted PDF via a CLI tool (two options; the default one can be overriden with a second parameter). To join semantic linefeeds in a fountain file before converting it with this script, see fountain2fountain.sh. To use both fountain2fountain.sh and this script, see fountain2fountain2pdf.sh.

# DEPENDENCIES
# Wrap or Afterwriting CLI (depending on which you choose and which code line you uncomment for either, respectively), and various GNU core utilities.

# USAGE
# Run with these parameters:
# - $1 fountain file name to convert.
# - $2 OPTIONAL. Anything, for example the word 'FLOREFLEFL.'. If omitted, the script will attempt to use the CourierMegaRS fonts in rendering PDFs (and will try to retrieve them via HTTP if they are not present). If included, wraps' default font (I think Courier Prime) is used.
# - $3 OPTIONAL. Anything, for example the word 'FLOREFLEF.' If ommited, the default pdf renderer (wrap) is used. If provided, the afterwriting renderer is used. $2 is overriden in this case (I have not figured out how to get afterwriting's janky custom font flags/config files working!)
# Example that uses the default renderer.
#    fountain2pdf.sh fountain-source-file.fountain
# Example that uses aftewriting:
#    fountain2pdf.sh fountain-source-file.fountain FLOREFLEF
# NOTES
# - The wrap CLI option expects custom fonts (which I made) to be in the current directory. If the script doesn't find those (or a signal one of them), it will attempt to download and extract a .7z archive of them. If that fails, it won't specify any custom fonts for rendering (which will cause the default to be used).
# - The optional last line of this script opens the output pdf.


# CODE
# TO DO: more elegant font locating? I don't want to assume they're one directory up.
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source fountain file name) passed to script. Exit."; exit 1; else sourceFountainFileName=$1; fi
if [ ! -e $sourceFountainFileName ]; then printf "\n~\nPROBLEM: proposed input file $sourceFountainFileName not found. Terminating script.\n"; exit 1; fi

font_option='courier_megaRS'
if [ "$2" ]; then font_option='renderers_default'; fi
renderer_option='wrap'
if [ "$3" ]; then renderer_option='afterwriting'; fi

fileNameNoExt=${sourceFountainFileName%.*}

# Eleven billionth time windows silly line endings mucked with a script; this fixes it:
if [ "$OS" == "Windows_NT" ]
then
	unix2dos $sourceFountainFileName
else
	dos2unix $sourceFountainFileName
fi

if [ "$renderer_option" == 'wrap' ]
then
# WRAP RENDER OPTION:
	echo will attempt to use wrap render option.
	if [ -e CourierMegaRS-SemiCondensed.ttf ] && [ "$font_option" != 'renderers_default' ]
	then
		printf "\nSignal font file CourierMegaRS-SemiCondensed.ttf found; will attempt to use . . ."
	else
		printf "\nSignal font file CourierMegaRS-SemiCondensed.ttf not found; will attempt to retrieve . . ."
		wget https://earthbound.io/data/dist/CourierMegaRSfonts.7z
		7z x -y CourierMegaRSfonts.7z
		rm ./CourierMegaRSfonts.7z
	fi
	# ~
	if [ -e CourierMegaRS-SemiCondensed.ttf ] && [ "$font_option" != 'renderers_default' ]
	then
# NOTE: WITHOUT &>/dev/null redirection, the following command caused wonky output from wrap to print to the terminal for MSYS2, and PDF write failed; the redirection to null fixed it (and caused a PDF to write okay) :
		echo WILL USE CUSTOM FONT IN RENDER . . .
		wrap pdf $sourceFountainFileName --font "CourierMegaRS-SemiCondensed.ttf, CourierMegaRS-SemiCondensedBold.ttf, CourierMegaRS-SemiCondensedItalic.ttf, CourierMegaRS-SemiCondensedBoldItalic.ttf" &>/dev/null
	else
		printf "\nAttempt to retrieve font files apparently failed (signal font file CourierMegaRS-SemiCondensed.ttf still not found); OR instructed via parameter to use default font; will use default font . . ."
		wrap pdf $sourceFountainFileName &>/dev/null
	fi
else
# AFTERWRITING CLI OPTION:
	echo will attempt to use afterwriting render option.
	afterwriting --source $sourceFountainFileName --overwrite --pdf
	# I gave my best effort and the following method of loading fonts is *stupid* arcane (*_two_ json files?!_*) and doesn't seem to work:
	# --config courierMegaConfig.json --fonts CourierMega.json
fi

# Optionally open result PDF; change `open` to `cygstart` for Cygwin:
#open ./$fileNameNoExt.pdf