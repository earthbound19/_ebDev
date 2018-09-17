# ex. service control commands:
# sc config "AeLookupSvc" start= demand
# sc config "NgcSvc" start= disabled

deleteServices="
gusvc \
gupdate \
gupdatem \
dbupdate \
dbupdatem \
WatAdminSvc \
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
BITS"

for element in ${disableServices[@]}
do
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
WPCSvc"

for element in ${onDemandServices[@]}
do
	echo RUNNING COMMAND\:
	echo SC CONFIG $element start= demand
	SC CONFIG $element start= demand
done

