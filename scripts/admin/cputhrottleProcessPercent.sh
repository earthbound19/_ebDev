# DESCRIPTION
# Uses `cputhrottle` (Mac) to throttle process $1 (1st parameter) to use max CPU percent $2 (parameter 2)

# DEPENDENCY
# cputhrottle: https://medium.com/@sbr464/limit-dropbox-and-others-on-macos-from-taking-100-cpu-877266df104d -- download and extract it from the zip file, then run these commands to install it:
#    sudo mv ./cputhrottle /bin
#    sudo chmod +x /bin/cputhrottle

# USAGE
# Run with these parameters:
# - $1 the process name to throttle
# - $2 the percent max CPU usage to throttle it to (as in 50 for 50 percent)
# Example
#    cputhrottleProcessPercent.sh Python 40
# You may need to precede the run of this script with sudo to get super admin permissions for it to control a process, like this:
#    sudo cputhrottleProcessPercent.sh Python 40
# It seems that it doesn't "take" the first time you run this script preceded by sudo if it stops and asks you for a password. Run this script preceded by sudo again, and it will take.


# CODE
cputhrottle $(pgrep -f $1) $2 &