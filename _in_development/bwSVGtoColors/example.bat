ECHO OFF
REM Observe how some of these programs are intelligent enough not to require the full path name, while others aren't ;)

nconvert -out bmp -overwrite -canvas #10 #10 center -bgcolor 0 0 0 test.png

REM Adds ten pixels on sides and top so fill will be consistent
REM potrace -n -s --group -r 10 -C #eff026 --fillcolor #c327f0 D:\Alex\Programming\_imageProcessing_static\bwSVGtoColors\test.bmp
potrace -n -s --group -r 24 -C #000000 --fillcolor #ffffff D:\Alex\Programming\_imageProcessing_static\bwSVGtoColors\test.bmp

REM Also, for vector scaling, see: http://superuser.com/a/516112/130772 and: http://stackoverflow.com/a/27919097/1397555
magick D:\Alex\Programming\_imageProcessing_static\bwSVGtoColors\test.svg D:\Alex\Programming\_imageProcessing_static\bwSVGtoColors\result.bmp
REM They will all need ten pixel side and top cropping, thusly:

REM Removes those added ten pixels on sides and top so the image will (if it is a tiling image) tile
nconvert -out png -overwrite -canvas #-10 #-10 center -bgcolor 0 0 0 result.bmp

REM TO DO: MKDIR <result>
REM TO DO: MOVE result.bmp <result>
REM TO DO: MOVE test.svg <result>
DEL result.bmp
DEL test.bmp

REM Satisfactory! Had begun exploring conversion with svgexport on nodejs/phantomjs . . . wait, maybe those will be more efficient. Testing . . .