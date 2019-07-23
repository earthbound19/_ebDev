# DESCRIPTION
# 42-minute work/break pomodoro timer.
# For 35 minutes, echoes a prompt to work. If you have a blink1 device, randomly
# change its color every 30 seconds for those 34 minutes.
# Then for 7 minutes echoes a prompt to break.
# Dims the screen to black and back quickly three times at that break prompt.
# Repeats this 10 times (7 hours). If you're working 8 hours, sprint to the finish!

# DEPENDENCIES
# homebrew, homebrew brightness package (Mac)

# USAGE
# Execute this script (`./macPomodoroBreakTimer.sh`) and let it
# run in the background as you work.
# If you have a blink device https://github.com/todbot/blink1/blob/master/docs/blink1-tool.md uncomment the blink1-tool commands and futz with the colors to your liking.

# WARNING
# If you terminate this script in an inverval of darkness, you will be left in darkness.
# DARKNESS, Batman. DARKNESS.

# DEVELOPER NOTE: `2> /dev/null` suppresses error print.

for x in $(seq 10); do
  echo "
---- BE DOING THE THINGS ----"
    # runs non-waiting command to make blink1 device randomly change color every 30 seconds:
    blink1-tool -t 30 --random=100;
    # echo "(blink command sent)"
  sleep $(echo "60 * 34" | bc)    # 60 seconds times 34 (34 minutes)
  echo "
---- BE TAKING A BREAK ----"
  for x in $(seq 3); do
    brightness 0 2> /dev/null; sleep 1; brightness 1 2> /dev/null; sleep 1.9;
      # Change blink1 device to bright yellow:
      blink1-tool --rgb fffbcc;
      # echo "(blink command sent)"
  done
  sleep $(echo "60 * 8" | bc)     # 60 seconds times 8 (8 minutes)
done
