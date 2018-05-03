# this script will launch whatever program you give it as parameter 1, returning to the shell (not waiting on the program) and without the program terminating when you exit the shell. re: http://apple.stackexchange.com/a/133148/219513

($1 &)