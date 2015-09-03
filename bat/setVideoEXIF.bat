ECHO OFF
REM NOTE: For this batch to work properly, the parameter passed to it must be surrounded by double quote marks.
REM mp4 Tags available to exiftool are the same as for quicktime, listed here: http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/QuickTime.html
REM Other info for exiftool and mp4: http://130.15.24.88/exiftool/forum/index.php?topic=6318.0
REM Tags available to add/update via ffmpeg are listed at: http://wiki.multimedia.cx/index.php?title=FFmpeg_Metadata#QuickTime.2FMOV.2FMP4.2FM4A.2Fet_al.
REM We're using: title, artist, keywords (for tags), description, copyright, and GenreID 4415 ("movies|special interest")
REM the optional -overwrite_original parameter specifies not to create a backup file.

exiftool -P -copyright="This work is an original creation owned and by Richard Alexander Hall. All rights reserved." -category="Experimental" -description="Rapid animated color noise scaled up many times preserving hard edges. Contrived from RGB values obtained from random.org. Could be used in various layering/compositing modes to add randomness to animated abstractions (e.g. to produce color fluctuation in an animated canvas, or to repeat in a ten hour animation with nyan cat music, to show to a toddler strapped into a chair, to provide them euphoria/a meltdown). " -artist="Richard Alexander Hall" -keywords="abstract, animation, art, abstract art, noise, color noise" -title=%1 %1

exiftool %1 > %1_tagInfo.txt