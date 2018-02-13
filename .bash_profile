# REFERENCE in case something janks up your environment and the default paths aren't echoed otherwise here for some reason:
# PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/MacGPG2/bin:/Library/TeX/texbin

# Custom prompt: dir only (I already know what user I'm running as, even if I elevate to root, so no need to display that) :
export PS1=" /\W 🐹 $ "

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

# RAH custom adds:
export PATH=$PATH:/Users/earthbound/Documents/breakTime/_ebPathMan
export PATH=$PATH:/Users/earthbound/Documents/breakTime/_ebDev
export PATH=$PATH:/Users/${USER}/Documents/_work_projects/best-practices

echo "APPLIED CUSTOM .bash_profile settings. Also $(buzzphrase)."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# REFERENCE for atom:
# # atom open-terminal-here override lines for keymap.cson to avoid conflicts with other packages:
# '.platform-darwin atom-workspace':
#   'ctrl-shift-alt-t': 'open-terminal-here:open'
#   'ctrl-alt-cmd-t': 'open-terminal-here:open-root'
# # atom open-terminal-here override command in settings; note that you must `npm install ttab -g` from the terminal first (ttab dependency):
# ttab && cd "$PWD"
# # OR follow instructions at end of open-terminal-here settings page in Atom?

# Android SDK, re: https://stackoverflow.com/a/17901693/1397555
export PATH=$PATH:/Users/${USER}/Library/Android/sdk/platform-tools

# Save future pain by backing up the current .bash_profile to a time-stamp-named file in a folder:
  # - Create the folder if it does not exist:
  if [ ! -d ~/bash_profile_bak ]; then mkdir bash_profile_bak; fi
timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
cat ~/.bash_profile > ~/bash_profile_bak/"$timestamp"_bash_profile_backup.txt
echo foo > bar.txt

# Added by n-install (see http://git.io/n-install-repo), a node version manager:
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"