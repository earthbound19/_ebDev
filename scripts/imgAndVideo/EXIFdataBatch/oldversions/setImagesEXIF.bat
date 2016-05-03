ECHO OFF
REM Explanation of some switches used with exiftool, re:
REM RE: http://www.sno.phy.queensu.ca/~phil/exiftool/exiftool_pod.html
REM RE: http://www.sno.phy.queensu.ca/~phil/exiftool/metafiles.html
REM The -r option causes sub-directories to be recursively processed.
REM -P (-preserve) preserves date/time of original file.
REM -all
	REM or -all (equals nothing) wipes all tags!
REM -Artist="Artist Name" is the name for a tag to be populated by the data after it (surrounded by quote marks).
REM etc.
REM What is -overwrite ?
REM use -u and U in backups!

ECHO exiftool -P -Copyright="Richard Alexander Hall, all rights reserved." -Artist="Richard Alexander Hall"

REM -Title="%1%"
REM OR? : -Headline="%1%"
REM Subject code arts painting, re http://xml.coverpages.org/NITF30-subject-codes.html :
	REM -SubjectCode="01012000"

REM -@ *ARGFILE*
         REM Read command-line arguments from the specified file. The file
         REM contains one argument per line (NOT one option per line -- some
         REM options require additional arguments, and all arguments must be
         REM placed on separate lines). Blank lines and lines beginning with "#"
         REM and are ignored. Normal shell processing of arguments is not
         REM performed, which among other things means that arguments should not
         REM be quoted and spaces are treated as any other character. *ARGFILE*
         REM may exist relative to either the current directory or the exiftool
         REM directory unless an absolute pathname is given.