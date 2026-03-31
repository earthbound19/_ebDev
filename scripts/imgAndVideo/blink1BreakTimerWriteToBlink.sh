# DESCRIPTION
# blink1 USB LED programming script to create work/break timer: slower speed random light changes for work period, faster speed random color changes for break period. 
# Stripped down version of blink1BreakTimer.sh which instead writes instructions to a blink device (flashes the device memory) so that it will play the pattern when connected to USB power (when it is not connected to a computer).

# USAGE
# With blink1-tool in your PATH (https://blink1.thingm.com/blink1-tool/), run this script:
#    blink1BreakTimerWriteToBlink.sh
# NOTES
# - Even though the math here "should" produce accurate minute/second intervals, in practice it doesn't.
# - The hard-coded math results in 1 faster flash before all the slower flash.


# CODE
# TO DO
# - figure out why, if I write the log of lines printed by this to a file, lines printed back by querying the device:
#    blink1-tool --getpattline <line number>
# -- don't match. Malforming the written number? Should it be hex-formatted somehow on write? But it still writes something. ??
# - option to get color palettes and use them from some external source (a palette serving API, which maybe I want to develop?

# DEVELOPER NOTES
# For a long time this script had a minute defined as 60000 ms (which is accurate), but I wondered why it didn't seem to time the lights that way. The answer is that I am controlling two lights, and it waits for the delay of one light to finish before it controls the other light. It therefore took twice as long with work minutes and break minutes.
# The solution is to define a minute as half a minute.
# ALSO, for a very long time I never noticed that write commands to the blink wrap around to 1 if you tell it to write to a line higher than 255; OR IN OTHER WORDS, on an mk3 model, you are limited to 255 pattern lines (if you go out of bounds it simply wraps around; it also seems to write the value to line 32 and on and other places). Which this scripts' original design didn't consider, and I wondered why it didn't seem to play back for the time periods I programmed. That there are 256 lines available is not clearly, prominently documented ANYWHERE, and I had to figure this out by trial and error.
# TO READ BACK THE WRITTEN PATTERN to a text file, use this command:
#    echo > wut.txt && for p in {0..255}; do blink1-tool --getpattline $p >> wut.txt; done
# NOTE: the sum of workMinutesInMSdivisor + breakBlinkColorChangeMS may not exceed 255--
# or you will not get the result you expect!
workBlinkNtimes=12
breakBlinkNtimes=243

workMinutes=35
  workMinutesInMS=$((workMinutes * 30000))
  workBlinkColorChangeMS=$((workMinutesInMS / workBlinkNtimes))
breakMinutes=8
  breakMinutesInMS=$((breakMinutes * 30000))
  breakBlinkColorChangeMS=$((breakMinutesInMS / breakBlinkNtimes))

echo "Will program $workBlinkNtimes color changes at $workBlinkColorChangeMS ms each (for work period) and $breakBlinkNtimes at $breakBlinkColorChangeMS ms each (for break period)."

# blink1-tool --playpattern '5,#ff00ff,0.4,0,#00ffff,0.4,0';
blink1-tool --clearpattern
blink1-tool --savepattern
for i in $(seq 0 2 $workBlinkNtimes)
do
  iPlusOne=$((i + 1))
 rndR=$(shuf -i 0-255 -n 1)
 rndG=$(shuf -i 0-255 -n 1)
 rndB=$(shuf -i 0-255 -n 1)
 # echo i $i iPlusOne $iPlusOne
blink1-tool --rgb=$rndR,$rndG,$rndB -m $workBlinkColorChangeMS -l 1 --setpattline $i
blink1-tool --rgb=$rndR,$rndG,$rndB -m $workBlinkColorChangeMS -l 2 --setpattline $iPlusOne
done

for j in $(seq $((workBlinkNtimes +1)) 2 $breakBlinkNtimes)
do
  jPlusOne=$((j + 1))
 rndR=$(shuf -i 0-255 -n 1)
 rndG=$(shuf -i 0-255 -n 1)
 rndB=$(shuf -i 0-255 -n 1)
  # echo i $i iPlusOne $iPlusOne
 blink1-tool --rgb=$rndR,$rndG,$rndB -m $breakBlinkColorChangeMS -l 1 --setpattline $j
 blink1-tool --rgb=$rndR,$rndG,$rndB -m $breakBlinkColorChangeMS -l 2 --setpattline $jPlusOne
done

# It works out that:
patternLinesCount=$jPlusOne

blink1-tool --savepattern
# setting startup pattern; set startup true (1,), run line (pos) 0-3, (0,3), run forever (0); re: https://github.com/todbot/blink1/blob/main/docs/blink1-tool-tips.md#play-the-blue-part-of-the-startup-sequence-forever
blink1-tool --setstartup 1,0,$patternLinesCount,0

echo ""
echo "DONE. $patternLinesCount""-line Pattern written and set to play on start. To see the pattern play, remove and re-insert the blink1."

# dev note: to see a specific line of the pattern run:
#    blink1-tool --getpattline <line number>
# re: https://github.com/todbot/blink1/blob/main/docs/blink1-tool-tips.md#play-the-blue-part-of-the-startup-sequence-forever

# OPTIONAL: play the pattern:
# blink1-tool --play 1