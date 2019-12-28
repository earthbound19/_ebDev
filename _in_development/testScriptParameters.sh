# DEMO of empty variable test.
# If this script is passed no parameters, both messages will print. If it is passed 1 param., only the second parameter will print. If passed two parameters, no msg. will print. To invert that situation, add a spaced negation operator ! in the if checks right before the -z.

if [ -z "$1" ]
	then
	echo msg 1
fi

if [ -z "$2" ]
	then
	echo msg 2
fi
