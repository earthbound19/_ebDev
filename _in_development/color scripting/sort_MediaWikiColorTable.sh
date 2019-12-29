# DESCRIPTION
# Sorts mediaWiki color tables by all possible HSL permutations without repetition (see NOTE comment below) of H(ue), S(aturation), and L(ightness), each permutation set being sorted by descending order, using Cygwin (~'nix) gsed and sort.
# USAGE
# Call this script with one parameter, being the text file to sort, *inline* -- meaning, THIS WILL DIRECTLY MODIFY whatever text file you pass to it.
## CODE

# NOTE: All possible permutations without repetion of the set {H|S|L} are: {Hue,Saturation,Lightness} {Hue,Lightness,Saturation} {Saturation,Hue,Lightness} {Saturation,Lightness,Hue} {Lightness,Hue,Saturation} {Lightness,Saturation,Hue}

# re http://stackoverflow.com/a/27783094/1397555
		# adjusted via a genius breath yon http://stackoverflow.com/a/13522361/1397555 :
		# <names.txt gsed 's/\([0-9]\)$/\10\2/' | sort --field-separator='=' -n -k 2,2 forColorSortTest.txt
		# NERP THAT; TRY:
# zero-pads two-digit numbers; assumes input has a space after each number we want to manipulate:
gsed -i 's/\([^0-9]\)\([0-9]\{2\} \)/\10\2/g' ./$1
# zero-pads one-digit numbers; assumes input has a space after each number we want to manipulate:
gsed -i 's/\([^0-9]\)\([0-9]\{1\} \)/\100\2/g' ./$1
# < temp2.txt put spaces back where they got lost for some reason in places before |.
gsed -i 's/\([^0-9]\)\(.*[0-9]\{1\}\)\( |\)/\1\2|/g' ./$1
# removes spaces before bars:
gsed -i 's/ |/|/g' ./$1

# Sort rows by column priority Hue, Saturation, Lightness.
	# {Hue,Saturation,Lightness}
sort --field-separator='=' -k 6n,6n -k 7n,7n -k 8n,8n ./$1 > $1_HSL.txt
	 # {Hue,Lightness,Saturation}
sort --field-separator='=' -k 6n,6n -k 8n,8n -k 7n,7n ./$1 > $1_HLS.txt
	 # {Saturation,Hue,Lightness}
sort --field-separator='=' -k 7n,7n -k 6n,6n -k 8n,8n ./$1 > $1_SHL.txt
	# {Saturation,Lightness,Hue}
sort --field-separator='=' -k 7n,7n -k 8n,8n -k 6n,6n ./$1 > $1_SLH.txt
	# {Lightness,Hue,Saturation}
sort --field-separator='=' -k 8n,8n -k 6n,6n -k 7n,7n ./$1 > $1_LHS.txt
	# {Lightness,Saturation,Hue}
sort --field-separator='=' -k 8n,8n -k 7n,7n -k 6n,6n ./$1 > $1_LSH.txt