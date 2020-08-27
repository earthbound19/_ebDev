:: DESCRIPTION
:: Enables you to save extremely large files more quickly and continue working on them even while they save. Accomplishes this by monitoring a RAMdisk for changes, and when changes are finished writing to the RAMdisk, syncs (backs up) files from the RAMdisk (nearly instantaneous storage in computer RAM or volatile memory, emulated as a hard drive) to slower storage (a hard drive). The caveat of a RAMdisk is that if you forget to copy files out of it when you're done working with it, they're gone quicker than you can say "No recycle bin." This batch alleviates that problem by continuously copying out of the RAMdrive (to a permanent storage location) in the background. However, even with this there comes a WARNING (see under USAGE).

:: DEPENDENCIES
:: - A RAMdrive, for example via the FOSS ImDisk utility available at http://www.ltr-data.se/opencode.html/#ImDisk
:: - The ROBOCOPY command, built into Windows since many versions ago.

:: WARNING
:: Because especially huge files (say, gigabytes large) can take much longer to save to a hard drive, even if you use this script (which backs up from RAMdrive to your hard drive continuously), you should take short breaks (perhaps at least a few minutes) every long now and then. Such breaks are good working sense to avoid fatigue anyway, but depending on the speed of your hard drive and the size of files you keep in the RAMdrive, such breaks may be needed to allow your computer to finish writing billions of bytes to disk. I don't know and have not tested what happens if you overwrite the same huge file in a RAMdrive before this batch finishes copying a previously written version of it to a hard drive.
:: Another way of saying that: if it takes longer than a minute to write the files you work with to your hard drive (permanent storage, not the RAM drive), and you overwrite the same file(s) on the RAM drive more than once a minute (by saving it again), which might mean you save to the RAM drive before this batch finishes copying it out of the RAM drive to the permanent staging location (SYNC_TO_DIR), this batch may never finish writing any file to permanent staging for far longer than you hope. Maybe not until you give the RAM drive enough rest time for it to do so. I don't know. Hopefully I will update this warning if I test that.
:: USAGE
:: Do in fact read that WARNING. To set up the environment to use this script and actually use it:
:: - Obtain, install and configure a RAM disk (such as from the URL given under DEPENDENCIES), as large you need and is suitable for your system.
:: - Create a folder which you will want to regularly and automatically sync files out of the RAM disk and into (continuous backup). For example: C:\Users\%username%\Desktop\_RAMdrive_mirror (where %username% is a Windows environment variable that means "your user folder." If you type %username% into Windows explorer and press <ENTER>, it will jump to your user folder.)
:: - Set the source (RAM drive) and destination (permanent hard drive storage) folders for this batch file in the first lines of code of RAMdriveLiveSync.bat, to folders which actually exist via your RAM drive and a hard drive, for example (and what it is hard-coded to by default) :
::        SET SYNC_FROM_DIR=V:\
::        SET SYNC_TO_DIR=C:\Users\%username%\Desktop\_RAMdrive_mirror
:: - Where SYNC_FROM_DIR will be the RAM drive (source) and SYNC_TO_DIR will be a permanent storage staging area (which should be a folder on a hard drive, not a RAM drive).
:: - With all that done, you're ready to work with files actively in the RAM drive source folder (a virtual folder created in memory!), after you double-click or otherwise run this batch:
::        RAMdriveLiveSync.bat
:: - Then, leave this batch running for as long as you work with the files in the RAM drive. (This means _leave the command prompt open_ -- or the terminal or "DOS box" or whatever you want to call it, running this batch--leave it open. Once per minute, the batch will copy all of their changes out of the RAM drive into the permanent staging location (SYNC_TO_DIR).
:: - When you are done working with the files, and they have synced to SYNC_TO_DIR, you will probably want to further relocate them to other permanent hard drive locations that make more sense.
:: NOTES
:: Previously I recommended the freeware program RAMdisk, available from http://www.dataram.com/ but that software was nerfed. The version I obtained allowed the RAMdisk to be up to 4GB in size, but the newest version now only allows up to 1GB. The free (and vs. the RAMdisk software I tested, easier to use) software I link to an obtain domain under DEPENDENCIES has no such limitations.


:: CODE
SET SYNC_FROM_DIR=V:\
SET SYNC_TO_DIR=C:\Users\%username%\Desktop\_RAMdrive_mirror
ROBOCOPY %SYNC_FROM_DIR% %SYNC_TO_DIR% /MIR /MT[:%NUMBER_OF_PROCESSORS%] /MON:1