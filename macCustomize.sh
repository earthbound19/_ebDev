# npm packages I regularly use:
# PREREQUISITE; npm:
while read element
  echo item is $element . .
done < ./npmPackages.txt

# Enable "Allow from Anywhere" in app gatekeeper on macOS Sierra (seriously, Apple, you are AWOL with your controls--I have to enable even the *option* to install apps from anywhere by entering a super-user terminal command?! Isn't that anti-competitive?), re: http://osxdaily.com/2016/09/27/allow-apps-from-anywhere-macos-gatekeeper/
sudo spctl --master-disable

# command for Atom open-terminal-here package on Mac (requires ttab to be installed) which allows opening any path to terminal by shortcut:
# ttab && cd "$PWD"