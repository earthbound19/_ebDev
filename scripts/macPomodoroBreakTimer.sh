# DESCRIPTION
# 42-minute work/break pomodoro timer.
# For 35 minutes, echoes a prompt to work.
# Then for 7 minutes echoes a prompt to break.
# Dims the screen to black and back quickly three times at that break prompt.
# Repeats this 10 times (7 hours). If you're working 8 hours, sprint to the finish!

# DEPENDENCIES
# homebrew, homebrew brightness package (Mac)

# USAGE
# Execute this script (`./macPomodoroBreakTimer.sh`) and let it
# run in the background as you work.

# WARNING
# If you terminate this script in an inverval of darkness, you will be left in darkness.
# DARKNESS, Batman. DARKNESS.

# DEVELOPER NOTE: `2> /dev/null` suppresses error print.

for x in $(seq 10); do
  echo "---- BE DOING THE THINGS ----"
  sleep $(echo "60 * 35" | bc)    # 60 seconds times 35 (35 minutes)
  echo "---- BE TAKING A BREAK ----"
  for x in $(seq 3); do
    brightness 0 2> /dev/null; sleep 1; brightness 1 2> /dev/null; sleep 1.9;
  done
  sleep $(echo "60 * 7" | bc)     # 60 seconds times 7 (7 minutes)
done
