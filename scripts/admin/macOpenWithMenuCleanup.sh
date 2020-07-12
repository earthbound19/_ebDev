# DESCRIPTION
# Cleans up the MacOS "Open with" menu.

# USAGE
#  macOpenWithMenuCleanup.sh


# CODE
# re: https://sixcolors.com/post/2015/10/clean-out-a-messy-open-with-menu-in-the-finder/
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user