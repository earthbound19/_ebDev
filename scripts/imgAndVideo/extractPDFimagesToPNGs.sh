# DESCRIPTION
# via pdfimages.exe (from Poppler utils in _ebSuperBin -- where I got the binaries is unknown! :|) and imgs2imgs.sh (with its dependencies), extracts all images from all PDFs in the current directory, as PPMs, and converts them to PNGs.

# DEPENDENCIES
# pdfimages.exe in your PATH, and imgs2imgs.sh with its dependencies.

# USAGE
# From a directory with pdfs, run without any parameters:
#    extractPDFimagesToPNGs.sh
# NOTE: pdftocairo, wherever you can get that, can do this in one step with:
# pdftocairo.exe -jpeg "my.pdf" "my"
# (I'm guessing you can change that to -png to convert to PNG)
# re: https://superuser.com/a/1276693


# CODE
pdfs=($(find . -iname \*.pdf -printf "%P\n"))

for fileName in ${pdfs[@]}
do
	fileNameNoExt=${fileName%.*}
	mkdir $fileNameNoExt
	extract_path=$fileNameNoExt
	wonky_extract_path_for_pdfimages_executable="$fileNameNoExt"/"$fileNameNoExt"_image
	pdfimages.exe $fileName $wonky_extract_path_for_pdfimages_executable
	pushd . &>/dev/null
	cd $extract_path
	imgs2imgs.sh ppm png
	rm *.ppm
	popd &>/dev/null
done

echo DONE extracting images from pdfs and converting them to pngs. They are in subfolders named after the source pdfs.