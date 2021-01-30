# DESCRIPTION
# Disables and even deletes contemptible or useless Windows services. This script is very shotgun "blast everything I even slightly don't like," including things you might want to keep around.

# WARNING
# May break essential system functionality or services that programs rely on. Use at your own risk.

# USAGE
# - Read the NOTES comment.
# - Don't use this script unless you're very sure that no harm or unwanted operations will come to your operating system or programs if you use it. If you're sure of that, then: from a cmd prompt with administrative privileges, and with `paexec` in your path:
# - run ntsu.bat to get a cmd prompt with NT/System authority.
# - From that NT/System cmd prompt, run e.g. either MSYS2 or a Cygwin emulation terminal. You may for example do the former with: `C:\msys64\msys2_shell.cmd`
# - Execute this script (you may need to cd to the directory with it first) :
#    fryStupidWindowsServices.sh
# Possible alternate route to merely disable unwanted services:
# - run ntsu.bat to get an NT/System Authority-priviledge prompt
# - run autoruns.exe (a utility that Microsoft bought from a developer) and
# - uncheck services you don't want to run, and anything else you don't want to run.
# OR from that NT/System Authority-priviledge prompt run:
#    sc delete "service name"
# NOTES
# Some unwanted services may be _created in a user context and only for a specific user, and with random characters after the service name. An example you'll find in this script is PimIndexMaintenanceSvc_339cb. Rename them in this script accordingly before running.
# As of Aug. 2018 (or earlier), Windows malignantly re-enables windows update and the commands here that seek to disable that don't work--services that switch windows update back on cannot be disabled.
# re: https://answers.microsoft.com/en-us/windows/forum/windows_10-other_settings/windows-10-windows-update-keeps-turning-it-self
# Example service control commands:
#    sc config "AeLookupSvc" start= demand
#    sc config "NgcSvc" start= disabled
# Other failed attempts, using subinacl utility:
#    wmic service where name='embeddedmode' call changeStartMode Disabled
#    subinacl /service embeddedmode /grant=<COMPUTERNAME>\Administrator=F
# Maybe that would work better as? :
# SUBINACL /SERVICE \\MachineName\ServiceName /GRANT=[DomainName]UserName[=Access]
# re: https://docs.microsoft.com/en-us/troubleshoot/windows-server/windows-security/grant-users-rights-manage-services


# CODE
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
nvUpdatusService \
brave \
bravem \
embeddedmode \
fhsvc \
DiagTrack \
RetailDemo \
WerSvc \
MozillaMaintenance"
# The above deletes Brave browser-related services because brave
# is cowardly and evil.
# Re: https://practicaltypography.com/the-cowardice-of-brave.html

for element in ${deleteServices[@]}
do
	echo RUNNING COMMAND\:
	echo SC DELETE $element
	SC DELETE $element
done

disableServices="
NgcSvc \
DoSvc \
NgcCtnrSvc \
Themes \
LicenseManager \
TabletInputService \
tiledatamodelsvc \
CscService \
wuauserv \
WaaSMedicSvc \
wscsvc \
WerSvc \
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
IEEtwCollectorService \
wlidsvc \
CDPSvc \
tiledatamodelsvc \
tapi \
TrkWks \
wcncsvc \
TrkWks \
Dnscache \
fdPHost \
SharedAccess \
GraphicsPerfSvc \
edgeupdatem \
SEMgrSvc \
RasAuto \
RasMan \
SessionEnv \
TermService \
UmRdpService \
RemoteRegistry \
shpamsvc \
SgrmBroker \
MessagingService_339cb \
PimIndexMaintenanceSvc_339cb \
BcastDVRUserService_339cb \
UdkUserSvc_339cb \
UserDataSvc_339cb \
UnistoreSvc_339cb \
UevAgentService \
WalletService \
Sense \
FontCache3.0.0.0 \
WinRM \
SecurityHealthService \
XboxGipSvc \
XblAuthManager \
XblGameSave \
XboxNetApiSvc \
AJRouter \
BITS"
# WSearch \

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
Fax \
Mcx2Svc \
StorSvc \
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