# DESCRIPTION
# Checks for install of homebrew on Mac and installs it if not detected.

# USAGE
# Run the script without any parameters:
#    installMacHomebrew.sh


# CODE
# re: https://brew.sh/
# Check if "which" command returns a path for brew. If it does, don't do anything other than print a notification that it is apparently installed. If it does not, assume brew is not installed, and install it.

returnFromWhichCheck=$(which brew)

if [ ! $returnFromWhichCheck == '' ]
then
  printf '\nThe return from $(which brew) is not blank; it appears that homebrew is already installed. Will not modify.'
else
  printf '\nThe return from $(which brew) is blank; it appears that homebrew is not installed. Will install.'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"2020-07-18 08:51 PM Saturday
fi