# DESCRIPTION
# Adds the path of whichever directory you call this script from to the PATH (temporarily, or for as long as you have the terminal open) as Python sees it.

# USAGE
# Run through a Python interpreter, without any parameter:
#    python /path/to_this_script/addCurrentPathToSyspath.py

# CODE
import os
currpath=os.getcwd()
import sys
sys.path.append(currpath)