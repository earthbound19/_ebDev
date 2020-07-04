imageTypeOperationsArray="
bmp \
cr2 \
crw \
gif \
jpeg \
jpg \
kra \
m4a \
mov \
mp4 \
ora \
pdf \
png \
psb \
psd \
ptg \
raw \
rif \
riff \
tif \
tiff \
eps \
svg"

# blank (or create) existing file, then overwrite it with elements from array:
printf "" > ~/imageTypeOperationsList.txt
for type in ${imageTypeOperationsArray[@]}
do
	echo $type >> ~/imageTypeOperationsList.txt
done