# DESCRIPTION
# Wipes all the silly .DS_Store metadata files from the MacOS drive. It can take forever. SEE ALSO macDevSetup.sh to set a preference to not write .DS_Store metadata files on network drives.

# USAGE
#  MacKillDSstoreFiles.sh


# CODE
# re: https://apple.stackexchange.com/a/32264/219513
find ~ -name .DS_Store -exec /bin/rm -f -- {} \;