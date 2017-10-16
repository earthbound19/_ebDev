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
BITS"

printf "" > tmp_YjAEjvnb.bat
for element in ${disableServices[@]}
do
	printf "SC CONFIG \"$element\" start= disabled\n" >> tmp_YjAEjvnb.bat
done
chmod +x tmp_YjAEjvnb.bat
tmp_YjAEjvnb.bat


onDemandServices="
AeLookupSvc \
DPS \
Fax \
HomeGroupListener \
HomeGroupProvider \
Mcx2Svc \
PcaSvc \
SharedAccess \
StorSvc \
WinDefend \
WinRM \
WPCSvc"

printf "" > tmp_YjAEjvnb.bat
for element in ${disableServices[@]}
do
	printf "SC CONFIG \"$element\" start= demand\n" >> tmp_YjAEjvnb.bat
done
chmod +x tmp_YjAEjvnb.bat
tmp_YjAEjvnb.bat

rm tmp_YjAEjvnb.bat