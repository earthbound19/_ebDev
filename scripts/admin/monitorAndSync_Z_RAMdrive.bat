REM refer to RAMdriveSyncBATdocumentation.pdf for installation and usage.
REM From: http://ramdrivesync.sourceforge.net
REM 01/01/2015 I release this batch to the Public Domain. - RAH
REM NOTE: You may want to change the number in this section of code:
REM		/MT[:2]
REM --to the number of processors in your computer's system. This enables the ROBOCOPY command to run multiple monitor/copy threads simultaneously.

SET SYNC_FROM_DIR=Z:\
SET SYNC_TO_DIR=_ZsavedFiles__StaticMirror
ROBOCOPY %SYNC_FROM_DIR% %SYNC_TO_DIR% /MIR /MT[:2] /MON:1