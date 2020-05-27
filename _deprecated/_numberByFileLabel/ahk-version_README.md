File Label And Number -- an AutoHotkey script for batch numbering and labeling of so many files, by order of creation date. I release this source code to the public domain. 05/21/2015 02:41:58 PM -RAH

Perhaps sometime I will write an appropriate introduction to this program right here, with useful instructions for use. Until then, if you have time on your hands to reverse-engineer my code, you may decipher for yourself what this program does! :)

IMPORTANT, ARCANE NOTES ONLY THE PROGRAMMER UNDERSTANDS:

In usage, drop a stub file with highest (base or start) number in the renaming folder on which this operates.

This script automatically renames files by adding ascending numbers and a given tag (e.g. _final_) to them, sorting by creation date. Earlier files will get lower numbers.

First parameter: full path to directory to be scanned, surrounded by quote marks if necessary
Second parameter: name tag for probed renamed tags
Third parameter: anything at all, and this tells the program to do some actual renaming (instead of only scanning and creating logs).

It will not number filenames that include the word "variant" in the file name. Also, files named _final which are not numbered but which are in a numbered folder may end up with a higher number than

OTHER NOTES to assimilate:
For this program to work as intended, you must follow the rules of naming files after this convention:
Offset the files you want counted with dashes or underscores (- or _). (It may be ok not to do this if the number is at the start of a filename.) Do not prefix the first underscore with the word "Library" or "Lib" (as some names generated from my batch scripts for Filter Forge do), and do not prefix or postfix the characters period or x (. or x or X).

I've tested whether files with the label _final in folders that also have that label will be numbered twice, and that seems not to be the case. But don't arrange your files that way--that's bad practice!
Five-digit numbered files might not be found by the program unless they are surrounded by - or _ characters. ALSO, warn that if there are numbers in folders other than the intended sorting five-digit numbers, it could mess up the folder names in ways the user doesn't want.

NOTE: To make use of this, art files which are finalized and ready for publication must be named *beginning* with _FINAL or _final (case doesn't matter). The script will sort and rename finalized works (so named) by date of creation.

(For the as-yet undescribed foldo mojo, that must also be _final)

YET OTHER NOTES to assimilate:
WARNING: Back up your files first! This program has no guarantees or warranty and could mess things up.

If you have a lot of files you *don't* want tagged with new numbers, and which are similarly named (e.g. "variant 01," "var. 02," "variation 05," etc.), this program may mess up in numbering. You can control for that by file naming. If you name every alternate/variation file "variant;" this program will deliberately ignore (not renumber) all those files.

Although this program sorts tagged files into new folders by number, if you have any files tagged _final already within a numbered folder, it will ignore the folder numbering, and number the tagged file regardless (which could result in files with a higher number in a lower-numbered folder). To avoid that happening where not intended, make sure that all _final files in any numbered folder are properly, similarly numbered!

This line in the source code:
  SetFormat, float, 05.0
--specifies that all numbering is five digit. THIS BREAKS for files that have more or less digits in their file name. TO DO: Fix that to auto-adapt to whatever the number of digits is, inculding in its renaming scheme.

== TASKS ==
TO DO items are in the source file comments.

== RELEASE HISTORY ==

v.0.4.3 05/21/2015 02:43:34 PM
Initial release!

== DEVELOPMENT LOG ==
2015/05/2015 A lot of unlogged development up to this date.
2015/11/24 resume development; reaquainting with use and testing for final usability.