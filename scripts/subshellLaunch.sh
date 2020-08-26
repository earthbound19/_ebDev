# DESCRIPTION
# Wrapper for a command structure to launch a subshell. Launches whatever program you pass as parameter $1, and returns to the shell (and does not wait on the program), and the program does not terminate when you exit the shell.

# USAGE
# Run with one parameter, which is the file name of a program or script (presumed to be in your PATH) to so execute. For example, to launch web_post_color_growth.sh in a process independent of the calling shell, run:
#    subshellLaunch.sh web_post_color_growth.sh


# CODE
# re: http://apple.stackexchange.com/a/133148/219513
($1 &)