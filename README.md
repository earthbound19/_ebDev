# DESCRIPTION
This repository was previously entitled _devtools.

A collection of scripts (most of them developed by me) which I use for development of many kinds--at this writing, mostly visual art development on Windows. It heavily relies on various 'nix/cygwin utilities, which at this writing you can obtain via a URL provided later in this document.

# LICENSE
Everything in this repository which I have created, I dedicate to the Public Domain, unless comments in or near any code state otherwise.

I believe that everything not created by me in this archive is at least freely available and open source. If you are the copyright owner of anything in this archive and wish for it to be removed, please contact me and I will do so.

[http://earthbound.io/contact](http://earthbound.io/contact "http://earthbound.io/contact")

09/02/2015 07:29:00 PM -RAH

# INSTALLATION AND USAGE

Horrible kludge note: through development history I have gone back and forth on using versions of four ported tools from unix: sed, find, sort, and uniq -- as copies from various windows/Mac ports but renamed as gsed, gfind, gsort, and guniq. At this writing, using renamed copies was more painful than using ones provided by MSYS2 than not. I just use them as sed, sort, find, and uniq. But there may be scripts in `/_in_development` and `/_deprecated` that still have the names I don't want to use anymore; to further develop or revive any of those use the proper (not `g`-prefixed) names.

## _ebSuperBin dependencies
- From a cygwin (or adapt for another 'nixy environment on Windows, or for similar utilities on a Mac) run the following command:
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
Windows and/or 'nixy environments: OR examine and use getDevEnv.sh per the comments therein.

NOTE that the tools and scripts in this repository are subject to high flux, because I edit and develop them as I use them, and/or because I freely add or remove utilities from this archive.

## ARCHIVE HISTORY
- 03/13/2016 04:20:39 PM Dramatically expanded/reorganized to include a lot more that I'm using, and have developed and/or moved. -RAH
- 09/02/2015 08:42:48 PM This was initially a project of only font development scripts. I upgraded it to be a repository of executables and scripts I use (and wrote). -RAH
- Late 2017 after scrapping this as a repo on account it was way too fat, discovered git lfs and resurrected repo, with lfs integration.
