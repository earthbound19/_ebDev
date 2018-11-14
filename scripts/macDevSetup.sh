pushd .

# NOPE: maybe asdf instead:
# install n node version manager; re: https://github.com/tj/n/issues/169
# cd ~
# curl -L https://git.io/n-install | bash
# TO UNINSTALL:
# ~/n/n-uninstall
# n latest

popd

./install_global_node_modules.sh

# Enable "Allow from Anywhere" in app gatekeeper on macOS Sierra (seriously, Apple, you are AWOL with your controls--I have to enable even the *option* to install apps from anywhere by entering a super-user terminal command?! Isn't that anti-competitive?), re: http://osxdaily.com/2016/09/27/allow-apps-from-anywhere-macos-gatekeeper/
sudo spctl --master-disable

# Enable cut-paste in Mac Finder (why would you *not* have that there by default, Apple?) :
defaults write com.apple.finder AllowCutForItems 1

# REFERENCE FOR OTHER TOOLS
# date format "Phrase content" for PhraseExpress text expander for mac, for hotkey/sequence to type full date and time:
#   {#datetime -f yyyy.mm.dd dddd t am/pm}

# command for Atom open-terminal-here package on Mac (requires ttab to be installed) which allows opening any path to terminal by shortcut:
# ttab && cd "$PWD"