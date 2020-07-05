# DESCRIPTION
This repository was previously entitled _devtools.

A collection of scripts, the vast majority of (if not all?) developed by me (earthbound19/RAH), which I use for development of many kinds--at this writing, maybe mostly development of visual and generative / new media art on Windows. Many of the scripts are tested on Windows and MacOS, and they may also work on many other versions of Linux-like operating systems (or envrionments), depending on which versions of various GNU utilities and Python are on (or which you can get) on those platforms.

See DEPENDENCIES and USAGE.

# LICENSE
Everything in this repository which I have created, I dedicate to the Public Domain, unless comments in or near any code state otherwise.

I believe that everything not created by me in this archive is at least freely available and open source. If you are the copyright owner of anything in this archive and wish for it to be removed, please contact me and I will do so.

[http://earthbound.io/contact](http://earthbound.io/contact "http://earthbound.io/contact")

09/02/2015 07:29:00 PM -RAH

# DEPENDENCIES

## _ebSuperBin / brew / other
- From an MSYS2 or cygwin prompt (MSYS2 preferred) (or adapt for another 'nixy environment on Windows, or for similar utilities on a Mac), run the following command:
    <!-- DEPRECATED but of potential future use (e.g. to grab the most current release): -->
    <!-- apt-cyg install p7zip -->
    <!-- wget http://earthbound.io/dist/_ebSuperBin.7z -->
    <!-- p7zip -d ./_ebSuperBin.7z -->
- `git clone https://github.com/earthbound19/_ebSuperBin.git` --which will give you an ./_ebSuperBin folder.
    <!-- ALSO DEPRECATED but of potential future use: -->
    <!-- OR instead of wget use curl: -->
    <!-- apt-cyg install curl -->
    <!-- curl http://earthbound.io/dist/_ebSuperBin.7z -->
- Windows: clone and make use of _setBinBaths.bat from https://github.com/earthbound19/_ebPathMan, which will permanently modify your path to include all relevant paths in this archive.
- Mac and/or other 'nixy environments (and Windows!) `getDevEnv.sh`

# USAGE
I try to put accessible usage and other documentation at the start of every script, under headings just like in this README.md itself: DESCRIPTION, USAGE, and sometimes DEPENDENCIES, KNOWN ISSUES, NOTES and maybe other headings.

Many or all scripts need to be in your PATH. If they are not in your PATH you must `cd` into their directory, or copy them to a directory with files they would operate on, and invoke them with `./` (meaning "this directory" to the terminal) and any parameters they require, as documented in each scripts' USAGE section. Examine that start comments in the source code of any script for guidance. If you 

### Developer notes

Tools and scripts in this repository are subject to high flux, because I edit and develop them as I use them, and/or because I may freely add or remove anything from this archive. Generally I move anything not useful (or redundant) to the `_deprecated` folder. Things under development or suspended for bugs are in the  `_in_development`. folder.

A history of a kludge: I have gone back and forth on using versions of four ported tools from unix: sed, find, sort, and uniq -- as copies from various windows/Mac ports but renamed as gsed, gfind, gsort, and guniq, in a subfolder of the `_ebSuperBin` repository which I keep in my PATH on Windows. But I found that MSYS2 updates would leave me with errors about possible cygwin1.dll version conflicts, and broken script runs. So I stopped copying/renaming those GNU utilities to that repo, and instead I use the ones as provided by MSYS2, which it keeps current and in the MSYS2 user bin folder(s), and as originally named: sed, sort, find, and uniq. But there may be scripts in `/_in_development` and `/_deprecated` that still have the names I don't want to use anymore; to further develop or revive any of those use the proper (not `g`-prefixed) names.