# DESCRIPTION
This repository is a collection of utilities, being executables and scripts (the latter of which I developed most of), which I use for development of many kinds--at this writing, mostly visual art development on Windows. It heavily relies on various 'nix/cygwin utilities.

I believe that everything here is at least freely available and open source. If you are the copyright owner of anything in this archive and wish for it to be removed, please contact me and I will do so.

[http://earthbound.io/contact](http://earthbound.io/contact "http://earthbound.io/contact")

09/02/2015 07:29:00 PM -RAH

# INSTALLATION AND USAGE:

Make a junction link to this directory, pointed to e.g. from one C:\devtools\_devbin, and put that same path in the system %PATH% (along with the paths to any other utilities or scripts in this repository that you will use). OR examine and use _setBinBaths.bat, which will permanently modify your path to include all relevant paths in this archive. OR examine and use getDevEnv.sh per the instructions therein.

To create a junction link, see: http://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html

Some scripts rely on the existence of a file which you must manually create in your home dir (type <cd ~><ENTER> in bash to view it) named _devToolsPath.txt. That file should have one line consisting of the path to the directory in which you install _devtools, e.g.:

C:\Users\<yourUserName>\Documents\scrap\_devtools-master

or

C:\_devTools

-- AND NOTE: If those paths include spaces or other "special" characters, it may not work. I'm not working around that. You must work around it by not using spaces etc. in your path.

The tools and scripts in this repository are subject to high flux, because I edit and develop them as I use them, and/or because I freely add or remove utilities from this archive.

This includes zeranoe's build of ffmpeg, AutoHotkey, and many gnu core utilities for windows 32-bit.

## ARCHIVE HISTORY:
- 09/02/2015 08:42:48 PM This was initially a project of only font development scripts. I upgraded it to be a repository of executables and scripts I use (and wrote). -RAH
- 03/13/2016 04:20:39 PM Dramatically expanded/reorganized to include a lot more that I'm using, and have developed and/or moved. -RAH