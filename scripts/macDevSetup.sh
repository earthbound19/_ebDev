# pushd .
# NOPE: maybe asdf instead:
# install n node version manager; re: https://github.com/tj/n/issues/169
# cd ~
# curl -L https://git.io/n-install | bash
# TO UNINSTALL:
# ~/n/n-uninstall
# n latest
# popd

./install_global_node_modules.sh

# Enable "Allow from Anywhere" in app gatekeeper on macOS Sierra (seriously, Apple, you are AWOL with your controls--I have to enable even the *option* to install apps from anywhere by entering a super-user terminal command?! Isn't that anti-competitive?), re: http://osxdaily.com/2016/09/27/allow-apps-from-anywhere-macos-gatekeeper/
sudo spctl --master-disable

# Enable cut-paste in Mac Finder (why would you *not* have that there by default, Apple?) :
defaults write com.apple.finder AllowCutForItems 1

defaults write com.apple.finder AppleShowAllFiles YES

# Possible additional commands to setup asdf and pyenv:
# git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.0
# echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
# asdf plugin-add nodejs
# asdf install nodejs 10.13.0
# asdf global nodejs 10.13.0
# xcode-select --install
# RE: https://github.com/pyenv/pyenv/issues/1219 :
# sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# git config user.email "earthbound19@users.noreply.github.com"
# git credential-osxkeychain 
# git config --global credential.helper osxkeychain
# curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash


# REFERENCE FOR OTHER TOOLS
# date format "Phrase content" for PhraseExpress text expander for mac, for hotkey/sequence to type full date and time:
#   {#datetime -f yyyy.mm.dd dddd t am/pm}

# command for Atom open-terminal-here package on Mac (requires ttab to be installed) which allows opening any path to terminal by shortcut:
# ttab && cd "$PWD"

# path change notes:
# see: https://coolestguidesontheplanet.com/add-shell-path-osx/
# 
# and / or http://hathaway.cc/post/69201163472/how-to-edit-your-path-environment-variables-on-mac