# re: https://apple.stackexchange.com/a/32264/219513
gfind ~ -name .DS_Store -exec /bin/rm -f -- {} \;

# Also re https://superuser.com/a/105247/130772 try sparing network drives from this cruft with:
defaults write com.apple.desktopservices DSDontWriteNetworkStores true