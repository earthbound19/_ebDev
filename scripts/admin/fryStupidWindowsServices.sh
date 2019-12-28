# WARNING: this script is very shotgun "blast everything," including things you might want to keep around.
#
# NOTES:
# - As of Aug. 2018 (or earlier), Windows malignantly re-enables windows update and the commands
# here that seek to disable that don't work--services that switch windows update back
# on cannot be disabled.
# re: https://answers.microsoft.com/en-us/windows/forum/windows_10-other_settings/windows-10-windows-update-keeps-turning-it-self
# SOLUTION: added those services to the deleteServices loop. If you run ntsu.bat (and have
# PAexec in your PATH, via my _ebSuperBin and _ebPathMan repos) to get a shell as System (super admin),
# and manually run SC DELETE on these services:
# osrss
# UsoSvc
# sedsvc
# wisvc
# -- it will delete those services (via the NT/Authority (system) account).
# This may also work if you run ntsu.bat, then:
# cd Cygwin64
# Cygwin.bat
# then run this script.
# - Also, to disable services that won't be disabled:
# run ntsu.bat to get an NT/System Authority-priviledge prompt
# run autoruns.exe (a utility that Microsoft bought from a developer) and
# uncheck services you don't want to run, and anything else you don't want to run.
# - ex. service control commands:
# sc config "AeLookupSvc" start= demand
# sc config "NgcSvc" start= disabled

rm -rf "C:\windows10update"

deleteServices="
gusvc \
gupdate \
gupdatem \
dbupdate \
dbupdatem \
WatAdminSvc \
osrss \
UsoSvc \
sedsvc \
wisvc \
MozillaMaintenance"

for element in ${deleteServices[@]}
do
	echo RUNNING COMMAND\:
	echo SC DELETE $element
	SC DELETE $element
done


disableServices="
NgcSvc \
DoSvc \
DiagTrack \
NgcCtnrSvc \
Themes \
LicenseManager \
TabletInputService \
tiledatamodelsvc \
CscService \
WSearch \
wuauserv \
wscsvc \
SysMain \
SwitchBoard \
FontCache \
ehRecvr \
ehSched \
WMPNetworkSvc \
FontCache3.0.0.0 \
HomeGroupListener \
HomeGroupProvider \
WinDefend \
AdobeUpdateService \
WerSvc \
IEEtwCollectorService \
wlidsvc \
CDPSvc \
tiledatamodelsvc \
BITS"

for element in ${disableServices[@]}
do
	echo RUNNING COMMAND\:
	echo SC STOP $element
	SC STOP $element
	echo RUNNING COMMAND\:
	echo SC CONFIG $element start= disabled
	SC CONFIG $element start= disabled
done


onDemandServices="
AeLookupSvc \
DPS \
Fax \
Mcx2Svc \
PcaSvc \
SharedAccess \
StorSvc \
WinRM \
WerSvc \
WPCSvc"

for element in ${onDemandServices[@]}
do
	echo RUNNING COMMAND\:
	echo SC STOP $element
	SC STOP $element
	echo RUNNING COMMAND\:
	echo SC CONFIG $element start= demand
	SC CONFIG $element start= demand
done

