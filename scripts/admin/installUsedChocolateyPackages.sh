# DESCRIPTION
# Installs all packages I commonly use from chocolatey.

# DEPENDENCIES
# chocolatey, with all its dependencies.
# See installChocolatey_instructions.txt to get chocolatey installed.

# USAGE
echo "EXCEPT THAT I'm not getting chocolatey to install anything on Windows 7 :("
exit

# Modify the array of packages per your wants. Then, run this script:
#  installUsedChocolateyPackages.sh

# CODE
chocolateyPackages=" \
hub \
7zip.install \
openssh \
libreoffice-fresh \
paint.net \
treesizefree \
chromium \
chocolateygui \
vlc "

# ccleaner \
# strawberryperl \
# ruby \
# pdfcreator \
# malwarebytes \
# putty.install \

for element in ${chocolateyPackages[@]}
do
  chocolatey uninstall $element
done
