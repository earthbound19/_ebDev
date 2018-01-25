REM from: http://www.majorgeeks.com/files/details/remove_windows_nag_icon_to_upgrade_to_windows_10.html

REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Gwx" /v DisableGWX /d 1 /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableOSUpgrade /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v AllowOSUpgrade /d 0 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v ReservationsAllowed /d 0 /f
TASKKILL /IM GWX.exe /T /F 

takeown /f "%windir%\System32\GWX" && icacls "%windir%\System32\GWX" /grant administrators:F

start /wait wusa /uninstall /kb:3035583 /quiet /norestart /log
exit