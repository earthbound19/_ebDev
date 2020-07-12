# DESCRIPTION
# Work/break pomodoro timer.
# Variables L, M, X, and Y in description are customizable.
# For L minutes (customizable), echoes a prompt to work. If you have a blink1 device, changes
# the device to a random color every M seconds during that work period.
# (Also with N millisecond color gradation change.) (SUGGESTION:
# don't change the blink color at all, or change it infrequently, during the work period.
# The blinking can distract.)
# Then for X minutes echoes a prompt to take a break. If you have a blink device,
# randomly changes the blink color every Y seconds (customizable) during break period Y.
# (Also with Z millisecond customizable color gradation change.)
# Also, dims the computer screen to black and back quickly three times at that break prompt.
# Repeats this cycle indefinitely.
# ANOTHER SUGGESTION: Every N break periods (4? 5?), take a long break.

# DEPENDENCIES
# homebrew, homebrew brightness package (Mac)

# USAGE
# Execute this script:
#  macPomodoroBreakTimer.sh
# -- and let it run in the background as you work.
# NOTES
# - if you do not have a blink device, uncomment the lines with the "sleep" commands.
# - you may alter the values under the "CHANGE THESE VALUES" comment.
# - depending on the way timer intervals divide (if the color change interval
# doesn't divide the break interval evenly), work and break periods may be a bit shorter
# than what you tell this script.
# WARNING
# If you terminate this script in an inverval of screen darkness, you will be left in darkness. DARKNESS, Batman. DARKNESS.

# DEVELOPER NOTES
# `2> /dev/null` suppresses error print.


# CODE
# USER VARIABLES
# CHANGE THESE VALUES to your liking:
workMinutes=35
  workMinutesInMS=$((workMinutes * 60000))
  workBlinkColorChangeIntervalMS=$((50000))   # ~every 50 seconds (in milliseconds)
  # How many times do we need to change the color to reach workMinutesInMS duration if
  # we change colors every workBlinkColorChangeIntervalMS? The following figures that out:
  workBlinkChangeColorTimes=`echo "$workMinutesInMS / $workBlinkColorChangeIntervalMS" | bc`
  workBlinkColorChangeMilliseconds=14000   # 14 seconds
breakMinutes=7
  breakMinutesInMS=$((breakMinutes * 60000))
  breakBlinkColorChangeIntervalMS=1400
  # How many times do we need to change the color to reach breakMinutes duration if
  # we change colors every breakBlinkColorChangeIntervalMS? The following figures that out:
  breakBlinkChangeColorTimes=`echo "$breakMinutesInMS / $breakBlinkColorChangeIntervalMS" | bc`
      # The following statements are for testing; comment them out in producton:
      echo "workBlinkChangeColorTimes value is $workBlinkChangeColorTimes over workMinutesInMS $workMinutesInMS"
      echo "breakBlinkChangeColorTimes value is $breakBlinkChangeColorTimes over breakMinutesInMS $breakMinutesInMS"
  breakBlinkColorChangeMilliseconds=1400


# WORK / BREAK LOOP
# At start of loop, flash blink device magenta and cyan 5 times, then 4 random colors:
blink1-tool --playpattern '5,#ff00ff,0.4,0,#00ffff,0.4,0';
blink1-tool --random=4 -l 1 -l 2 -q;
# do work/break loop / echoes / blinking lights:
while (true); do    # eternal loop
    # OPTIONALLY at start of work loop, dim screen to black and then full brightness again, once:
  # brightness 0 2> /dev/null; sleep 0.8; brightness 1 2> /dev/null;
    # echo prompt for work run:
  echo "
---- DO THE THINGS ----"
    # blink color prompt for work run;
    # blink1 device randomly change color every M seconds, randomly change both lights, quiet mode;
    # via semicolon is non-waiting command; no idea whether no gamma correction (-g) effects anything:
  blink1-tool -g -t $workBlinkColorChangeIntervalMS --random=$workBlinkChangeColorTimes --millis=$workBlinkColorChangeMilliseconds -l 1 -l 2 -q;
        # UNCOMMENT the next line only if you don't have a blink device:
        # sleep $(echo "60 * $workMinutes" | bc)    # workMinutes times 60 seconds per minute
  echo "
---- TAKE A BREAK ----"
    # OPTIONALLY fade computer monitor in and out of black 3 times to prompt to take a break:
  # for x in $(seq 3)
  # do
  #   brightness 0 2> /dev/null; sleep 0.8; brightness 1 2> /dev/null; sleep 0.8;
  # done
    # blink color prompt for break; similar to that for work run (see comments above):
  blink1-tool -t $breakBlinkColorChangeIntervalMS --random=$breakBlinkChangeColorTimes --millis=$breakBlinkColorChangeMilliseconds -l 1 -l 2 -q;
        # UNCOMMENT the next line only if you don't have a blink device:
        # sleep $(echo "60 * $breakMinutes" | bc)    # breakMinutes times 60 seconds per minute
done

# DEVELOPMENT CODE
# SAVES a random color boot pattern to a blink1 (USB-powered LED) device via
# blink1-tool (Mac).
# Wipe whatever pattern may be on the device:
# blink1-tool --clearpattern ; blink1-tool --savepattern
# Because if you try to save a --random= to the blink device it saves black,
# we have to generate our random color specifically in this script and save it.
# So, wenerate an RND color for pattern line N (counting from 0 to N):
# for i in $(seq 1000)
# do
#	This could be done more efficiently by pregenerating so much randomness
#	and cutting sections off it, as in other scripts, but;
#	(re: https://unix.stackexchange.com/a/140751) :
	# rndR=`shuf -i 0-255 -n 1`
	# rndG=`shuf -i 0-255 -n 1`
	# rndB=`shuf -i 0-255 -n 1`
#	echo "writing $rndR,$rndG,$rndB"
	# blink1-tool -m 400 -t 600 --rgb $rndR,$rndG,$rndB --setpattline $i
# done

# save that pattern to the blink as a bootup (USB only--no computer) pattern:
#blink1-tool --savepattern



# REFERENCE
# blink1-tool command reference/examples:
# https://github.com/todbot/blink1/blob/master/docs/blink1-tool.md

# BLINK1-TOOL CLI HELP:
# blink1-tool <cmd> [options]
# where <cmd> is one of:
# --list                      List connected blink(1) devices 
# --rgb=<red>,<green>,<blue>  Fade to RGB value
# --rgb=[#]RRGGBB             Fade to RGB value, as hex color code
# --hsb=<hue>,<sat>,<bri>     Fade to HSB value
# --blink <numtimes>          Blink on/off (use --rgb to blink a color)
# --flash <numtimes>          Flash on/off (same as blink)
# --on | --white              Turn blink(1) full-on white 
# --off                       Turn blink(1) off 
# --red                       Turn blink(1) red 
# --green                     Turn blink(1) green 
# --blue                      Turn blink(1) blue 
# --cyan                      Turn blink(1) cyan (green + blue) 
# --magenta                   Turn blink(1) magenta (red + blue) 
# --yellow                    Turn blink(1) yellow (red + green) 
# --rgbread                   Read last RGB color sent (post gamma-correction)
# --setpattline <pos>         Write pattern RGB val at pos (--rgb/hsb to set)
# --getpattline <pos>         Read pattern RGB value at pos
# --savepattern               Save RAM color pattern to flash (mk2)
# --clearpattern              Erase color pattern completely 
# --play <1/0,pos>            Start playing color pattern (at pos)
# --play <1/0,start,end,cnt>  Playing color pattern sub-loop (mk2)
# --playstate                 Return current status of pattern playing (mk2)
# --playpattern <patternstr>  Play Blink1Control pattern string in blink1-tool
# --writepattern <patternstr> Write Blink1Control pattern string to blink(1)
# --readpattern               Download full blink(1) patt as Blink1Control str
# --servertickle <1/0>[,1/0,start,end] Turn on/off servertickle (w/on/off, uses -t msec)
# --chase, --chase=<num,start,stop> Multi-LED chase effect. <num>=0 runs forever
# --random, --random=<num>    Flash a number of random colors, num=1 if omitted 
# --glimmer, --glimmer=<num>  Glimmer a color with --rgb (num times)
# Nerd functions: 
# --fwversion                 Display blink(1) firmware version 
# --version                   Display blink1-tool version info 
# --setstartup                Set startup parameters (v206+,mk3) 
# --getstartup                Get startup parameters (v206+,mk3) 
# and [options] are: 
# -d dNums --id all|deviceIds Use these blink(1) ids (from --list) 
# -g -nogamma                 Disable autogamma correction
# -m ms,   --millis=millis    Set millisecs for color fading (default 300)
# -q, --quiet                 Mutes all stdout output (supercedes --verbose)
# -t ms,   --delay=millis     Set millisecs between events (default 500)
# -l <led>, --led=<led>       Which LED to use, 0=all/1=top/2=bottom (mk2+)
# --ledn 1,3,5,7              Specify a list of LEDs to light
# -v, --verbose               verbose debugging msgs
# 
# Examples: 
# blink1-tool -m 100 --rgb=255,0,255    # Fade to #FF00FF in 0.1 seconds 
# blink1-tool -t 2000 --random=100      # Every 2 seconds new random color
# blink1-tool --led 2 --random=100      # Random colors on both LEDs 
# blink1-tool --rgb 0xff,0x00,0x00 --blink 3  # blink red 3 times
# blink1-tool --rgb '#FF9900'           # Make blink1 pumpkin orange
# blink1-tool --rgb FF9900 --led 2      # Make blink1 orange on lower LED
# blink1-tool --chase=5,3,18            # Chase pattern 5 times, on leds 3-18
# 
# Pattern Examples: 
# # Play purple-green flash 10 times (pattern runs in blink1-tool so blocks)
# blink1-tool --playpattern '10,#ff00ff,0.1,0,#00ff00,0.1,0'
# # Change the 2nd color pattern line to #112233 with a 0.5 sec fade
# blink1-tool -m 500 --rgb 112233 --setpattline 1 
# # Erase all lines of the color pattern and save to flash 
# blink1-tool --clearpattern ; blink1-tool --savepattern 
# 
# Servertickle Examples: 
# # Enable servertickle to play pattern after 2 seconds 
# # (Keep issuing this command within 2 seconds to prevent it firing)
# blink1-tool -t 2000 --servertickle 1 
# # Enable servertickle after 2 seconds, play sub-pattern 2-3 
# blink1-tool -t 2000 --servetickle, 1,1,2,3 
# 
# Setting Startup Params Examples (mk2 v206+ & mk3 only):
# blink1-tool --setstartup 1,5,7,10  # enable, play 5-7 loop 10 times
# blink1-tool --savepattern          # must do this to save to flash 
# 
# Notes: 
# - To blink a color with specific timing, specify 'blink' command last:
#  blink1-tool -t 200 -m 100 --rgb ff00ff --blink 5 
# - If using several blink(1)s, use '-d all' or '-d 0,2' to select 1st,3rd: 
#  blink1-tool -d all -t 50 -m 50 -rgb 00ff00 --blink 10 