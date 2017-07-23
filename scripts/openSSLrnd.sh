# DESCRIPTION
# Get N random bytes (from parameter $1) using openssl.

# USAGE
# To write N random bytes to a file via this script, invoke it thusly; here, 512 can be changed to any number of bytes you wish to generate:
# ./thisScript.sh 512 > rnd.dat

# DEPENDENCIES
# openssl.

openssl rand $1