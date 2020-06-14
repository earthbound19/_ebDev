REM ?? https://support.microsoft.com/en-us/help/947821/fix-windows-update-errors-by-using-the-dism-or-system-update-readiness-tool

REM run from an administrator command prompt re: https://davescomputertips.com/sfc-fails-to-fix-errors-what-now/

Dism /Online /Cleanup-Image /CheckHealth
Dism /Online /Cleanup-Image /ScanHealth
REM Dism /Online /Cleanup-Image /RestoreHealth
REM OR e.g.; re: https://www.windowscentral.com/how-use-dism-command-line-utility-repair-windows-10-image
REM Dism /Online /Cleanup-Image /RestoreHealth /Source:C:\Recovery\whatever path\Winre.wim

SFC /scannow