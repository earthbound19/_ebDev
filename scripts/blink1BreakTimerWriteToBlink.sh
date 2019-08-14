# DESCRIPTION
# Stripped down version of blink1BreakTimer.sh which instead writes instructions to a blink device
# (flashes the device memory) so that it will play the pattern when connected to USB power
# (when it is not connected to a computer)

workMinutes=35
  workMinutesInMS=$((workMinutes * 60000))
  workBlinkColorChangeMS=9000
  workBlinkChangeColorTimes=`echo "$workMinutesInMS / $workBlinkColorChangeMS" | bc`
breakMinutes=7
  breakMinutesInMS=$((breakMinutes * 60000))
  breakBlinkColorChangeMS=1460
  breakBlinkChangeColorTimes=`echo "$breakMinutesInMS / $breakBlinkColorChangeMS + $workBlinkChangeColorTimes" | bc`

# blink1-tool --playpattern '5,#ff00ff,0.4,0,#00ffff,0.4,0';
blink1-tool --clearpattern
for i in $(seq 0 2 $workBlinkChangeColorTimes)
do
  iPlusOne=$((i + 1))
 rndR=`shuf -i 0-255 -n 1`
 rndG=`shuf -i 0-255 -n 1`
 rndB=`shuf -i 0-255 -n 1`
 blink1-tool -m $workBlinkColorChangeMS --rgb $rndR,$rndG,$rndB -l 1 --setpattline $i
 blink1-tool -m $workBlinkColorChangeMS --rgb $rndR,$rndG,$rndB -l 2 --setpattline $iPlusOne
done

for j in $(seq $((workBlinkChangeColorTimes +2)) 2 $breakBlinkChangeColorTimes)
do
  jPlusOne=$((j + 1))
  rndR=`shuf -i 0-255 -n 1`
  rndG=`shuf -i 0-255 -n 1`
  rndB=`shuf -i 0-255 -n 1`
  blink1-tool -m $breakBlinkColorChangeMS --rgb $rndR,$rndG,$rndB -l 1 --setpattline $j
  blink1-tool -m $breakBlinkColorChangeMS --rgb $rndR,$rndG,$rndB -l 2 --setpattline $jPlusOne
done
 blink1-tool --savepattern
 blink1-tool --play 1