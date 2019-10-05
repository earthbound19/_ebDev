# DESCRIPTION
# uses cputhrottle (Mac) to throttle process $1 (1st parameter) to use max CPU percent $2 (parameter 2)

# USAGE
# invoke this script with two parameters, being the process name to throttle and the percent max CPU usage to throttle it to (as in 50 for 50 percent; for example:
# cputhrottleProcessPercent.sh Python 40
# NOTE that you may need to precede the invocation with sudo to get super admin permissions for it to control a process.

# DEPENDENCY
# cputhrottle: https://medium.com/@sbr464/limit-dropbox-and-others-on-macos-from-taking-100-cpu-877266df104d -- download and extract it from the zip file, then run these commands to install it:
# sudo mv ./cputhrottle /bin
# sudo chmod +x /bin/cputhrottle


# CODE
cputhrottle $(pgrep -f $1) $2 &