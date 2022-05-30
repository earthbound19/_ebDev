# DESCRIPTION
# Get N random bytes (from parameter $1) using openssl.

# DEPENDENCIES
# openssl

# USAGE
# To write N random bytes to a file via this script, run it this way; here, 512 can be changed to any number of bytes you wish to generate:
#    openSSLrnd.sh 512 > rnd.dat


# CODE
openssl rand $1