:: DESCRIPTION
:: Deletes an over-the-top so wrong nag to update Windows 7 to 10 (which was an absolute fiasco for many users), which Microsoft pushed on all users via an update.

:: USAGE
:: Run this batch without any parameters:
::    delwin10nag.bat


:: CODE
:: from: http://www.majorgeeks.com/files/details/remove_windows_nag_icon_to_upgrade_to_windows_10.html

REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Gwx" /v DisableGWX /d 1 /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v AllowOSUpgrade /d 0 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v ReservationsAllowed /d 0 /f
TASKKILL /IM GWX.exe /T /F 

takeown /f "%windir%\System32\GWX" && icacls "%windir%\System32\GWX" /grant administrators:F

start /wait wusa /uninstall /kb:3035583 /quiet /norestart /log
