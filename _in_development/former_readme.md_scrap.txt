UPDATE these notes to reflect setup changes involving the _ebPathMan repo/toolset, and put it back in the README.md; also get such a process in place for Mac:
--

Some scripts rely on the existence of a file which you must manually create in your $HOME dir named _devToolsPath.txt. In cygwin, to learn your home dir, enter the command "cygpath -w ~" or in any (?) 'nix environment, try the command "echo $HOME". The file _devToolsPath.txt should have one line consisting of the path to the directory in which you install _ebdev, e.g.:

C:\Users\yourUserName\Documents\scrap\_ebdev-master

or e.g.:

C:\artDevTools

An example command to create this would be:

echo C:\\_devTools > $HOME/_devToolsPath.txt

(The \\ there is to escape the backslash so it will actually print into the file.)

-- AND NOTE: If those paths include spaces or other "special" characters, it may not work. I'm not working around that. You must work around it by not using spaces etc. in your path.