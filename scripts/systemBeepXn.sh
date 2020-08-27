# DESCRIPTION
# Plays a system "beep" N times (per default or parameter $1), with a pause in between each beep. Useful as a notification after run of a command that takes a long time.

# USAGE
# Note that your terminal settings need to have any system beep enabled (for MSYS2 you can find this under the options with a right-click of the terminal menu bar). If that is set, run this script without an optional parameter:
# - $1 How many times to play the sound. If not provided, a default is used.
# Example that would play 5 beeps (or whatever sound the system makes):
#    systemBeepXn.sh 5
# Example that will play the default number of beeps:
#    systemBeepXn.sh
# To run this script after another script (for example as a notification after a long process ends), follow the run command of that script with a double-ampersand && and then the call of this script, for example:
#    makeDocumentation.sh && systemBeepXn 7


# CODE
# DEVELOPER NOTE
# You can also do this with Python: python -c "print('\7\7\7\7\7\7\7')"
if [ "$1" ]; then nTimes=$1; else nTimes=5; fi

for i in $(seq 1 $nTimes)
do
	echo -en "\007"
	sleep 0.65
done

