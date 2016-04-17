# DESCRIPTION: This script concatenates so many text files in subdirectories, then strips trivial information from them. Intended to build corpuses for e.g. gibberish generating. NOTE: This is custom built to create a corpus from the accouncements archive at e-flux.com. It could be adapted for other purposes. Also, note that this script will throw errors about things being directories; these errors don't affect anything negatively and can be ignored.

# USAGE: from a shell, navigate to a directory that has so many text files in itself and/or subdirectories. Execute this script. Results will be written to corpus.html and cleaned up to serve as a corpus.

# TESTS ONLY:
rm corpus.html
sleep 1

	# re: http://stackoverflow.com/a/24069223/1397555 -- I haven't figured how to filter to only html files, but all the files I have are html \(there is no other type\), so that's moot anyway; COMPILE all files into one file:
echo Merging all text files in all subdirectories into one file . . .
# find * -exec cat {} \; >> corpus.html
cat *.txt > corpus.html
	# Trim everything except for the actual announcment text out of the resultant corpus (trim everything that does *not* match the following pattern); thanks to: http://stackoverflow.com/a/2686369
# OPTION TO TOGGLE HERE:
# echo Isolating everything nested in col1 / div tags . . .
# ECXEPT NOT WHEN dealing with plain text as there is some bug with that . . . maybe it deletes everything if there's no match? YEESH if so:
# sed -i '/.*col1\"/,/<\/div>.*/I!d' corpus.html
# exit

# PARTICULAR TO the e-flux announcements collection. Comment out if inapplicable.
	# nuke all lines containing the words separated by \| ; with help from http://superuser.com/a/112000/130772 and http://stackoverflow.com/a/4412964/1397555 :
echo Removing all paragraphs that contain these words: enquiry\|enquiries\|contact\|contacts\|information\|application
sed -i '/.*enquiry\|enquiries\|contact\|contacts\|information\|application.*/Id' corpus.html

# Delete with prejudice all paragraphs where another html tag appears within the first 8 characters of the source code (which will usually be a bolded name or title that our corpus isn't concerned with):
echo Deleting all paragraphs that have bold/italics with the first two words \(these are almost always name credits etc.\) . . .
sed -i '/<p>.\{1,8\}<b.*/,/.*<\/p>.*/d' corpus.html

echo Deleting with prejudice all lines that include numbers and are less than or equal to ~140 characters \(as these are almost always contact info etc.\) . . .
sed -i '/[^0-9]\{1,70\}[0-9]\{1,\}[^0-9]\{1,70\}$/d' corpus.html

echo Deleting all img tags . . .
sed -i 's/\(.*\)<img.*>\(.*\)/\1\2/g' corpus.html

# OPTIONS FOR DOCUMENTS with so many HTML/XML tags, so much email header and quoted junk, to delete all that:
sed -i 's/<.*>//g' corpus.html
sed -i 's/^X.*:.*//g' corpus.html
sed -i 's/^>>>.*//g' corpus.html
sed -i 's/^>>.*//g' corpus.html
sed -i 's/^>.*//g' corpus.html

# formail [or procmail?] -c -z -e -k -X Subject:
	# OR? /To extract the body from a message:
	# formail -I ""

	# DEPRECATED as irrelevant, as we are now manually using an HTML editor to open and then save the document as plain text; and it caused all text to lump together on one line besides:
		# Replace all <p> tags with newlines:
	# sed -i 's/<p>/\n/g' corpus.html
		# Delete all resultant straggling and unecessary closing </p> tags:
	# sed -i 's/<\/p>//g' corpus.html

	# Delete all link anchor tags; BORKEN, deletes too much; TO DO; FIX:
# sed -i 's/\(.*\)<a\ .*\(.*\).*<\/a>/\1\2/g' corpus.html

		# DEPRECATED because it doesn't convert html character codes to their unicode equivalents, and it lumps all text on one line besides: delete all html tags; thanks to: http://stackoverflow.com/a/7593836/1397555
	# sed -i 's/<[^>]\+>/ /g' corpus.html

# Amend the document with proper html and most importantly encoding declarations, at the start and end. Necessitates copying the whole corpus into a temp file.
# Write an appropriate html header and encoding declaration to the file first; everything else will be appended to the file (including the necessary closing html tags after the corpus text body); note that the angle brackets and double-quote marks are escaped with \ :
echo Adding proper HTML headers and footers to corpus.html . . .

echo \<\!doctype html\>\<html lang=\"en\"\>\<head\>\<meta charset=\"utf-8\"\>\</head\>\<body\> > temp1.txt
cat temp1.txt corpus.html > temp2.txt
rm temp1.txt
# Write the html closing tags to the document:
echo \<\/body\>\<\/html\> >> temp2.txt
rm ./corpus.html
mv ./temp2.txt ./corpus.html

# Remove any goofy and unecessary leading spaces that result:
sed -i 's/^ \(.*\)/\1/g' corpus.html

echo
echo =============================
echo =============================
echo DONE. Open corpus.html into e.g. the Seamonkey browser \(firefox or libreOffice Writer both failed for *huge* corpuses\), then save it as plain-text. In the case of Writer, and if necessary, save using a character set \(e.g. windows Western Europe\) that supports characters not available in ASCII.
