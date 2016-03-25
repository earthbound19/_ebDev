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

ECHO exiftool -P -Copyright="Richard Alexander Hall, all rights reserved." -Artist="Richard Alexander Hall"
REM -Title="%1%"
REM OR? : -Headline="%1%"
REM Subject code arts painting, re http://xml.coverpages.org/NITF30-subject-codes.html :
	REM -SubjectCode="01012000"