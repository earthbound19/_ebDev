:: DESCRIPTION
:: Performs a Windows image repair / cleanup, then system file scan and repair.

:: USAGE
:: From a command prompt with administrative privileges, run this script:
::    windows_DISM_onlineRepair.bat
:: REFERENCE URLS
:: - https://support.microsoft.com/en-us/help/947821/fix-windows-update-errors-by-using-the-dism-or-system-update-readiness-tool
:: - https://davescomputertips.com/sfc-fails-to-fix-errors-what-now/


:: CODE
Dism /Online /Cleanup-Image /CheckHealth
Dism /Online /Cleanup-Image /ScanHealth
:: Dism /Online /Cleanup-Image /RestoreHealth
:: OR e.g.; re: https://www.windowscentral.com/how-use-dism-command-line-utility-repair-windows-10-image
:: Dism /Online /Cleanup-Image /RestoreHealth /Source:C:\Recovery\whatever path\Winre.wim

SFC /scannow