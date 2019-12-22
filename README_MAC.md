# Package managers and dev setup on Mac:
- Run this command, with the version string matching your version of MacOS: `sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /` -- re: https://github.com/pyenv/pyenv/issues/1219
- `python`: versions managed via `pyenv` (I think I used asdf and ran into trouble)
- `nodejs`: versions managed via `asdf`
- Setup and miscellaneous utilities: managed via `macDevSetup.sh` and `installUsedBrewPackages.sh`
- `compileInstallGraphicsMagick_on_mac.sh`

Other mac-related scripts in this repo:
- macFindProcess.py
- macNodeJSsetup.sh
- macOpenWithMenuCleanup.sh
- MacKillDSstoreFiles.sh
- rebuildMacSpotlightIndex.sh