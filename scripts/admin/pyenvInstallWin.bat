REM DESCRIPTION
REM Installs pyenv on Windows. NOTE: I have not gotten good use of pyenv on
REM windows yet. I reinstalled in several different ways and finally got it to
REM change python versions, but then pip didn't work.
REM re: https://github.com/pyenv-win/pyenv-win
REM NOTE the special steps necessary (put it sooner in path) for Windows 10.

REM DEPENDENCIES
REM windows, git, setenv, and modpath (the latter two from _ebPathMan or
REM elsewhere). ALSO, this script must be run from an administrator command
REM prompt, and the environment variables won't take effect until you restart
REM the commmand prompt).

REM USAGE
REM From an administrator command prompt, with this script in your PATH,
REM run this script. AFTERWARD, restart an command prompt with administrator
REM priviliges, and run:
REM pyenv install x.x.x
REM --where x.x.x is the python version you want--then run:
REM pyenv global x.x.x
REM (giving the same version again for x.x.x)--then run:
REM pyenv rehash
REM (You may need to run that rehash command every time you change the global version).

REM DEV NOTES
REM Why two path modification tools? Because setenv creates variable
REM name/value pairs, and modpath is better at adding to the SYSTEM PATH
REM varaible. (Couldnae get setenv to.)


REM CODE
REM DEPRECATED, as the repo is neglected:
REM git clone https://github.com/pyenv-win/pyenv-win.git %USERPROFILE%/.pyenv
	REM DEPRECATED setx command:
	REM setx PYENV "%USERPROFILE%\.pyenv\pyenv-win" /M
setenv -m PYENV "%USERPROFILE%\.pyenv\pyenv-win"

REM Add these to PATH via modpath, which overcomes the character limit that
REM isn't actually a limit, re: https://superuser.com/q/387619/130772:
REM BACK UP the PATH to a text file in case anything borkes!:
echo %PATH% > PATHBAK.txt
REM NOTE that where another tool didn't require double %% (escaped percent signs)
REM to add do the path, this one does?! WHATEVS:
modpath.exe /add "%%PYENV%%\bin"
modpath.exe /add "%%PYENV%%\shims"