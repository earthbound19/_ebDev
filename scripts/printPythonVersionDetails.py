# DESCRIPTION
# Prints detailed python platform/version information.

# USAGE
# Run from a Python interpeter without any parameters to the script:
#    python /path/to/this/script/printPythonVersionDetails.py


# CODE
import sys
import platform
print('\nPYTHON INFORMATION:\n', sys.version)
print(platform.platform(), '\n')