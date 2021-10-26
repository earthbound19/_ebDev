# DESCRIPTION
# Loads an unencrypted password from your Unix profile root directory (which you should not do unless you're confident no one can access it, and probably not even then), and uses that to authenticate to a remote terminal via putty.

# USAGE
# Run with one parameter:
# - $1 the username of your intended remote session.
# For example:
#    puttyAuth.sh beeblebrox@panic.org

# KEYWORDS
# Remote terminal, authentication, remote shell, putty, ssh


# CODE
# TO DO
# - Use utils to encrypt the password with an at least more secure password in the file read into this; decrypt-able only with that password.
# - OR THIS: https://www.howtoforge.com/how-to-configure-ssh-keys-authentication-with-putty-and-linux-server-in-5-quick-steps
if ! [ "$1" ]; then echo "No parameter \$1 (username) passed to script. Exit."; exit; else username=$1; fi

pw=$(< ~/puttyAuth.txt)
putty.exe $username -pw $pw &