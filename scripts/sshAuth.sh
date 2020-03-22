# NOTE: the following is not advisable. Use a private key encrypted and secured by
# operting system secure storage instead; re:
# https://apple.stackexchange.com/questions/48502/how-can-i-permanently-add-my-ssh-private-key-to-keychain-so-it-is-automatically

# also not advisable is sharing a remote authentication username in a git repo :/

pass=$(< ~/ussinsor.txt)
echo IS: $pass
ssh ussinsor@ussins.org