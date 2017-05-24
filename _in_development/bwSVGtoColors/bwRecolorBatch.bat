nconvert -out bmp -overwrite -canvas #10 #10 center -bgcolor 0 0 0 2015-04-23__09.35.23_PM.png

potrace -n -s --group -r 72 -C #010101 --fillcolor #efefef 2015-04-23__09.35.23_PM.bmp

MKDIR D:\Alex\Programming\bwRecolor\2015-04-23__09.35.23_PM_result

COPY D:\Alex\Programming\bwRecolor\2015-04-23__09.35.23_PM.svg D:\Alex\Programming\bwRecolor\2015-04-23__09.35.23_PM_result\2015-04-23__09.35.23_PM.svg && DEL 2015-04-23__09.35.23_PM.bmp