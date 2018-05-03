	# Pregenerate random characters to pull shorter random character strings from:
	# re: http://stackoverflow.com/a/1405641
	numRandomCharsToGet=`echo $(( arrSize * getNrandChars ))`
		# echo numRandomCharsToGet val is $numRandomCharsToGet
	randomCharsString=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $numRandomCharsToGet`
		# echo randomCharsString val is $randomCharsString

# Initialize counter at negative the number of getNrandChars, so that the first iteration in the following loop will set it to 0, which is where we need it to start:
multCounter=-$getNrandChars
	# echo multCounter val is $multCounter
for filename in ${array[@]}
do
		# Get file extension, re: http://stackoverflow.com/a/30863119/1397555
		# Extension (all) : '1.0.1.tar.gz'
		fileExt=`echo "$filename" | awk '{sub(/[^.]*[.]/, "", $0)} 1'`
			# echo fileExt val is $fileExt
		# For file renaming, grab next n random characters from pre-generated randomCharsString:
		# num=$(($multCounter + $num2))
			# echo multCounter val is $multCounter
			# echo getNrandChars vlas is $getNrandChars
		multCounter=$(($multCounter + $getNrandChars))
			# echo getNrandChars val is $getNrandChars
		newFileBaseName=${randomCharsString:$multCounter:$getNrandChars}