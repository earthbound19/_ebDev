# DESCRIPTION
# Very simple openSSL wrapper: get N ($1) random bytes from it.

# DEPENDENCIES
# OpenSSL.

# USAGE
# Call with these parameters:
# - $1 number of random bytes to generate using OpenSSL.
# Example that will get 512 random bytes:
#    openSSLrnd.sh 512
# To write N random bytes to a file via this script, pipe the output to a file:
#    openSSLrnd.sh 512 > rnd.dat


# CODE
openssl rand $1