REM TO DO: Find the exact name of the FlashP* / FlashU* executables and use the found name to terminate those.
sc stop Everything
sc stop DisplayFusionService
sc stop "Bonjour Service"
sc stop "iPod Service"
sc stop "Apple Mobile Device Service"
sc stop SbieSvc
sc stop PcaSvc
sc stop AeLookupSvc
REM sc stop MBAMScheduler
REM sc stop MBAMService
sc stop wscsvc
sc stop mi-raysat_3dsmax2013_64
sc stop LMS
sc stop jhi_service
sc stop "Intel(R) Capability Licensing Service Interface"
REM IT SEEMS that one of the following services, as of 09/25/2017, causes explorer.exe to hang when you attempt to delete a junction; as stopping all the following services eliminates the problem:
sc stop PSI_SVC_2_x64
sc stop PSI_SVC_2
sc stop DbxSvc
sc stop mi-raysat_3dsmax2013_32
sc stop ProtexisLicensing
sc stop RemoteSolverDispatcher
sc stop VMwareHostd
sc stop VMAuthdService
sc stop VMnetDHCP
sc stop "VMware NAT Service"
sc stop VMUSBArbService
sc stop AGSService
sc stop "Bonjour Service"
sc stop MMCSS
sc stop sppsvc
sc stop TabletInputService
sc stop gupdate
SC DELETE gupdate
sc stop BrYNSvc
sc stop bthserv
sc stop "AMD External Events Utility"
sc stop WerSvc
process -k iexplore.exe
process -k dropbox.exe
process -k greenshot.exe
process -k robotaskbaricon.exe
process -k DisplayFusionHookApp64.exe
process -k DisplayFusionHookApp32.exe
process -k DisplayFusion.exe
process -k CCC.exe
process -k COCIManager.exe
process -k slack.exe
process -k secd.exe
process -k iTunesHelper.exe
process -k BrStMonW.exe
process -k vmware-usbarbitrator64.exe
process -k uTorrent.exe
process -k iCloudDrive.exe
process -k ApplePhotoStreams.exe
process -k iCloudServices.exe
process -k steamwebhelper.exe
process -k Steam.exe
process -k RadeonSettings.exe
process -k sqlwriter.exe
REM Adobe CC-related processes:
process -k "Adobe Desktop Service.exe"
process -k AdobeICPbroker.exe
process -k CoreSync.exe
process -k CCXprocess.exe
process -k CCLibrary.exe