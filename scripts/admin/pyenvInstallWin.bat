:: DESCRIPTION
:: Installs pyenv on Windows. NOTE: I have not gotten good use of pyenv on windows yet. I reinstalled in several different ways and finally got it to change python versions, but then pip didn't work. re: https://github.com/pyenv-win/pyenv-win

:: DEPENDENCIES
:: windows, git, setenv, and modpath (the latter two from _ebPathMan or elsewhere).

:: NOTES
:: - This script must be run from an administrator command prompt, and the environment variables won't take effect until you restart the commmand prompt).
:: - Observe the special steps necessary (put it sooner in path) for Windows 10.
:: USAGE
:: Run from an administrator command prompt:
::    pyenvInstallWin
:: AFTERWARD, restart a command prompt with administrator privileges, and run:
::    pyenv install x.x.x
:: --where x.x.x is the python version you want. Then run:
::    pyenv global x.x.x
:: (With the same version again for x.x.x.) Then run:
::    pyenv rehash
:: You may need to run that rehash command every time you change the global version.


:: CODE
:: DEV NOTES
:: Why two path modification tools? Because setenv creates variable
:: name/value pairs, and modpath is better at adding to the SYSTEM PATH
:: variable. (Couldnae get setenv to.)
:: DEPRECATED, as the repo is neglected:
:: git clone https://github.com/pyenv-win/pyenv-win.git %USERPROFILE%/.pyenv
	:: DEPRECATED setx command:
	:: setx PYENV "%USERPROFILE%\.pyenv\pyenv-win" /M
setenv -m PYENV "%USERPROFILE%\.pyenv\pyenv-win"

:: Add these to PATH via modpath, which overcomes the character limit that
:: isn't actually a limit, re: https://superuser.com/q/387619/130772:
:: BACK UP the PATH to a text file in case anything borkes!:
echo %PATH% > PATHBAK.txt
:: NOTE that where another tool didn't require double %% (escaped percent signs)
:: to add do the path, this one does?! WHATEVS:
modpath.exe /add "%%PYENV%%\bin"
modpath.exe /add "%%PYENV%%\shims"