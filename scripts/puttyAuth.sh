# WARNING: storing your password in an unencrypted file anywhere is a bad idea.

# TO DO:
# Use utils to encrypt the password with an at least more secure password in the file read into this; decrypt-able only with that password.
# OR THIS: https://www.howtoforge.com/how-to-configure-ssh-keys-authentication-with-putty-and-linux-server-in-5-quick-steps

# KEYWORDS
# Remote terminal, authentication, remote shell, putty, ssh


# CODE
pw=$(< ~/puttyAuth.txt)
putty.exe ussinsor@ussins.org -pw $pw &