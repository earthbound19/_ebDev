# TO INSTALL THIS FILE, run this command:
# cp ./bash_profile ~/.bash_profile

# Custom prompt: dir only (I already know what user I'm running as, even if I elevate to root, so no need to display that) ; systems that have no idea what a hamster emoji is :) may just display a garbage or "unknown unicode" character:
export PS1="$(buzzphrase) /\W 🐹 $ "

# Number of lines to keep (1000 in this example)
export HISTFILESIZE=2100

# Set how many commands to keep in the current session history list
export HISTSIZE=80

# Ignore commands that start with a space
export HISTIGNORE="&:[ ]*:exit"

# Re: https://serverfault.com/a/414762
LANG=
LC_COLLATE="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
export LANG=en_US.UTF-8

export PATH=/Users/earthbound/Documents/breakTime/_ebPathMan:$PATH
export PATH=/Users/earthbound/Documents/breakTime/_ebDev:$PATH

echo "APPLIED CUSTOM .bash_profile settings. Also $(buzzphrase)."


# DEPRECATED:
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
