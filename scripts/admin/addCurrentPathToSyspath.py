# DESCRIPTION: Adds the path of whichever directory you call this script from to the system path as Python sees it.
# USAGE: from a shell in a directory where this script is copied to, invoke it thus:
# python addCurrentPathToSyspath.py

import os
currpath=os.getcwd()
import sys
sys.path.append(currpath)
# print (sys.path)