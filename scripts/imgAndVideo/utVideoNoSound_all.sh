# currDir=`$pwd`
find *.avi > all_avis.txt
mapfile -t allAVIs < all_avis.txt
for element in "${allAVIs[@]}"
do
	utVideoNoSound.sh "$element"
done