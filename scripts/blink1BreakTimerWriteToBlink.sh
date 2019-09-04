# DESCRIPTION
# Stripped down version of blink1BreakTimer.sh which instead writes instructions to a blink device
# (flashes the device memory) so that it will play the pattern when connected to USB power
# (when it is not connected to a computer). Even though the math here "should" produce
# accurate minute/second intervals, in practice it doesn't.

# DEVELOPER NOTES
# For a long time this script had a minute defined as 60000 ms (which is accurate), but
# I wondered why it didn't seem to time the lights that way. The answer is that I am controlling
# two lights, and it waits for the delay of one light to finish before it controls the other
# light. It therefore took twice as long with work minutes and break minutes.
# The solution is to define a minute as half a minute.


workMinutes=35
  workMinutesInMS=$((workMinutes * 30000))
  workBlinkColorChangeMS=$((workMinutesInMS / 12))
  workBlinkChangeColorTimes=`echo "$workMinutesInMS / $workBlinkColorChangeMS" | bc`
breakMinutes=8
  breakMinutesInMS=$((breakMinutes * 30000))
  breakBlinkColorChangeMS=1400
  breakBlinkChangeColorTimes=`echo "$breakMinutesInMS / $breakBlinkColorChangeMS + $workBlinkChangeColorTimes" | bc`

# blink1-tool --playpattern '5,#ff00ff,0.4,0,#00ffff,0.4,0';
blink1-tool --clearpattern
blink1-tool --savepattern
for i in $(seq 0 2 $workBlinkChangeColorTimes)
do
  iPlusOne=$((i + 1))
 rndR=`shuf -i 0-255 -n 1`
 rndG=`shuf -i 0-255 -n 1`
 rndB=`shuf -i 0-255 -n 1`
 # echo i $i iPlusOne $iPlusOne
 blink1-tool -m $workBlinkColorChangeMS --rgb $rndR,$rndG,$rndB -l 1 --setpattline $i
 blink1-tool -m $workBlinkColorChangeMS --rgb $rndR,$rndG,$rndB -l 2 --setpattline $iPlusOne
done

for j in $(seq $((workBlinkChangeColorTimes +1)) 2 $breakBlinkChangeColorTimes)
do
  jPlusOne=$((j + 1))
  rndR=`shuf -i 0-255 -n 1`
  rndG=`shuf -i 0-255 -n 1`
  rndB=`shuf -i 0-255 -n 1`
  # echo j $j jPlusOne $jPlusOne
  blink1-tool -m $breakBlinkColorChangeMS --rgb $rndR,$rndG,$rndB -l 1 --setpattline $j
  blink1-tool -m $breakBlinkColorChangeMS --rgb $rndR,$rndG,$rndB -l 2 --setpattline $jPlusOne
done

blink1-tool --savepattern
blink1-tool --play 1