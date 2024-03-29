# DESCRIPTION
# Iterates over all directories in a hard-coded array and runs `git pull` for each. Script enforces only calling it with a local script call (./pa.sh), and not from PATH search and find of this script.

# USAGE
# Copy this script (`pull_all.sh`) to a folder containing some git repository local clones, and rename it to `pa.sh`. Then in the copied script, alter the repo_directories array (in the code) for your wishes. Then, to pull all those clones automatically, open your terminal to that directory (or cd to it), and run this script:
#    ./pa.sh
# NOTES 
# - This script will only run if called that way: `./pa.sh` (as a script file in your immediate terminal directory). If this script is in your PATH and you try to run it with `pa.sh`, it will detect that, and notify you of the problem and exit.
# - The original save name of this script is pull_all.sh, which is another protection from that accident. You would have to rename this to pa.sh in the original directory you were instructed to copy this from to make that mistake, but it would still warn you.


# CODE
# Check if $0 (script path) is ./pa.sh. If it is not, it means this script was run from another directory (that it was found in from searching directories in PATH), and not from the users' current terminal directory. And if so, there will be unexpected behavior, so notify and exit. (Enforces calling this script only via the command `./pa.sh` (local), and never from `pa.sh` (PATH search) :
if ! [ "$0" == "./pa.sh" ]; then echo "Script not called via ./pa.sh command. Call this script only as ./pa.sh. Exiting script."; exit; fi

repo_directories=(
_ebPalettes
_ebDev
_ebPathMan
_ebSuperBin
autobrood
)

parent_directory=$(pwd)
for directory in ${repo_directories[@]}
do
	cd $directory
	printf "\n\nSyncing local git repos with remotes. . .\n"
	git pull
	git fetch --prune
	cd $parent_directory
done