# DESCRIPTION
# Changes colors on a blink LED USB light randomly, forever. See USER VARIABLES to hack the timing.

# DEPENDENCIES
# blink1-tool

# USAGE
# Execute this script without any parameter:
#    blinkRandomColors.sh


# CODE
# USER VARIABLES
# CHANGE THESE VALUES to your liking:
intervalMinutes=7
intervalMinutesInMS=$((intervalMinutes * 60000))
blinkColorChangeIntervalMS=1400
 # How many times do we need to change the color to reach intervalMinutes duration if
 # we change colors every blinkColorChangeIntervalMS? The following figures that out:
blinkChangeColorTimes=$(echo "$intervalMinutesInMS / $blinkColorChangeIntervalMS" | bc)
blinkColorChangeMilliseconds=1400

# echo intervalMinutes $intervalMinutes
# echo intervalMinutesInMS $intervalMinutesInMS
# echo blinkColorChangeIntervalMS $blinkColorChangeIntervalMS
# echo blinkChangeColorTimes $blinkChangeColorTimes
# echo blinkColorChangeMilliseconds $blinkColorChangeMilliseconds

# random colored blinking lights forever:
while :
do    # eternal loop
  blink1-tool -t $blinkColorChangeIntervalMS --random=$blinkChangeColorTimes --millis=$blinkColorChangeMilliseconds -l 1 -l 2 -q;
done