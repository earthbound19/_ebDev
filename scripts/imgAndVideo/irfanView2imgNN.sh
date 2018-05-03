# USAGE
# Invoke this script with three parameters, being:
# $1 input file
# $2 output format
# $3 px wide to resize to by nearest neighbor method, maintaining aspect

# TO DO
# Name output file after input file base name plus new extension


# CODE
# Command switches used to build up command; re: http://www.robvanderwoude.com/files/iviewcli.txt
# /resize_long=X        - resize input image: set long side to X
	# RELATED options not used here:
	# /resize=(w,h)         - resize input image to w (width) and h (height)
	# /resize_short=X       - resize input image: set short side to X
# /aspectratio          - used for resizes: keep image proportions
# /convert=filename     - convert input file(s) to "filename" and CLOSE IrfanView
# example for resize:
# i_view32.exe c:\test.jpg /resize=(300,300) /resample

imgFileNoExt=`echo "${1%.*}"`
i_view32.exe $1 /resize_long=$3 /aspectratio /convert=$imgFileNoExt.$2
