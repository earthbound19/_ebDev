# DESCRIPTION: Generate a text file with n passwords of criteria: n random lowercase letters, n random uppercase characters, n random special characters, n random digits--in random order.

# USAGE: where n is the desired number of passwords:
# passGen.sh 50
# Results are not written to any file; to write them to a file, call this script with a redirect to an output file e.g. thusly:
# passGen.sh 50 > passwords.txt

# LICENSE: I programmed this and release it to the public domain. 2015/10/19 11:18:39 AM -RAH

# Excellent password-building reference:
# https://www.grc.com/haystack.htm
# https://apps.cygnius.net/passtest/

# TO DO: Rewrite this to be far more efficient by creating character groups in larger, bulk temp files (using only one call to create many characters for each group), then extract from the files--or even better, from in-memory variables--and repeatedly diminish the files (variables) upon extraction. See fileNumberByLabel.sh for how to do this.

howMany=$1
# printf "making $howMany password(s) . . ."

scramble() {
    # $1: string to scramble
    # return in variable scramble_ret
    local a=$1 i
    scramble_ret=
    while((${#a})); do
        ((i=RANDOM%${#a}))
        scramble_ret+=${a:i:1}
        a=${a::i}${a:i+1}
    done
}

# printf "" > passwords.txt
lower=1
upper=2
special=1
number=3
pad_one=7
# TO DO: ways to add more unpredictability/entropy; e.g. having two pad strings, and possibility of splitting padding throughout or at the edges of the password; so that we have e.g.:
# pad_two=4


for (( i=1; i<=$howMany; i++ ))
do
	# NOTE that letters and numbers which can easily be confused with others are ommited from the randomization source.
	# four random lowercase alphabetical characters:
	str1=`cat /dev/urandom | tr -dc 'a-hj-km-np-z' | head -c $lower`
	# two random uppercase alphabetical characters:
	str2=`cat /dev/urandom | tr -dc 'A-HJ-KM-NP-Z' | head -c $upper`
	# one random special character:
	str3=`cat /dev/urandom | tr -dc '!@#$%^\&~_()[]{};:",.<>/?' | head -c $special`
	# one number:
	str4=`cat /dev/urandom | tr -dc '23456789' | head -c $number`
	password="$str1$str2$str3$str4"
			# DEPRECATED in favor of the (entirely in memory, I believe) approach given in the lines after these indented lines:
			# Thanks to yet another genius breath yon: http://stackoverflow.com/a/26326317/1397555
			# echo $password | sed 's/./&\n/g' | shuf | tr -d "\n" >> passwords.txt
	scramble $password
	password=$scramble_ret


	# =================================================
	# BEGIN *FIRST* PAD PASSWORD WITH A RANDOM CHARACTER REPEATED.
	# echo password before padding is $password
		# Pad n times (value of $pad_one) with random char:
		# padChar=`cat /dev/urandom | tr -dc '!@#$%^\&~_()[]{};:",.<>/?23456789' | head -c 1`
		padChar=`cat /dev/urandom | tr -dc '!@#$%^\&~_()[]{};:",.<>/?' | head -c 1`
		# padChar=`cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z!@#$%^\&~_ ()[]{};:",.<>/?23456789' | head -c 1`
		for (( j=1; j<=$pad_one; j++ ))
		do
			temp=$temp$padChar
		done
	padStr=$temp
	temp=

		passwordLength=${#password}
				# echo "passwordLength is $passwordLength"
		chopMax=$passwordLength
				# Random number in range of password length, again adapted from a brilliant bloke here: http://stackoverflow.com/a/2556282/1397555
		splitWhere=`shuf -i 0-$chopMax -n 1`
				# echo "splitWhere is $splitWhere"

		# if splitWhere is 0 (do not split; pad_one start), add padded string to start.
		if [[ $splitWhere == 0 ]]
		then
			password=$padStr$password
		fi

		# if splitWhere is 0 (do not split; pad_one end), add padded string to end.
		if [[ $splitWhere == $passwordLength ]]
		then
			password=$password$padStr
		fi

		# add padded string in case where splitWhere is 1 to length of (password - 1) (effectively) 
		if [[ $splitWhere > 0 && $splitWhere < $passwordLength ]]
		then
		((passwordCutIDX = passwordLength - splitWhere))
				# echo "passwordCutIDX is $passwordCutIDX"
		splitPassStart=`echo $password | cut -c1-$splitWhere`
				# echo "splitPassStart is $splitPassStart "
		((endCutStartIDX=$splitWhere + 1))
		splitPassEnd=`echo $password | cut -c$endCutStartIDX-$passwordLength`
				# echo "splitPassEnd is $splitPassEnd "
		password=$splitPassStart$padStr$splitPassEnd
		fi
	# END *FIRST* PAD PASSWORD WITH A RANDOM CHARACTER REPEATED.
	# =================================================
	
	# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	# =================================================
	# BEGIN *SECOND* PAD PASSWORD WITH A RANDOM CHARACTER REPEATED.

	
	# Except my first copy paste and adjust of the above code didn't work . . . ?

	
	# END *SECOND* PAD PASSWORD WITH A RANDOM CHARACTER REPEATED.
	# =================================================

	# printf " . . ."
	echo $password
done


# NOTES:
# Other stuff I may never use:
# http://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
# http://code.runnable.com/UpulVcyngwQdAAAo/random-password-generator-for-shell-and-bash
# Although that is a virtual console--cool! I may have uses for that.
# And, uh, I mighta horked something from yon. Dunna remember: http://stackoverflow.com/questions/26665389/random-password-generator-bash

# shuffle the characters on every line of the passwords file so that the pattern above (n lowercase, n uppercase, n special and n number) is no longer a pattern; so that the selection of characters are in any order:
# shuf passwords.txt > temp.txt
# rm passwords.txt
# mv temp.txt passwords.txt