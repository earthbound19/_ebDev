:: DESCRIPTION
:: Terminates a wide variety of processes which may be found on Windows computers which I often consider extraneous or even resource hogging, including stopping such services. I don't recommend anyone to just run this script nilly-willy unless you are very sure you don't need the processes in it to run (as I am sure for myself, but I have only examined them for my own purposes, which my vary from yours).

:: DEPENDENCIES
:: process.exe Command Line Process Viewer/Killer/Suspender for Windows, from beyondlogic.org installed in your PATH.

:: USAGE
:: Run without any parameters:
::    killHogApps.bat


:: CODE
:: TO DO: Find the exact name of the FlashP* / FlashU* executables and use the found name to terminate those.
:: I am experimenting with disabling the secondary logon service, "seclogon."
:: Also, it may be more secure to disable the network list service, "netprofm."
sc stop tvnserver
sc stop Everything
sc stop "Bonjour Service"
sc stop "iPod Service"
sc stop "Apple Mobile Device Service"
sc stop SbieSvc
sc stop PcaSvc
sc stop AeLookupSvc
sc stop fdPHost
sc stop FDResPub
sc stop RpcSs
sc stop RpcEptMapper
sc stop ss_conn_service
sc stop ss_conn_service2
sc stop VSStandardCollectorService150
:: sc stop MBAMScheduler
:: sc stop MBAMService
sc stop wscsvc
sc stop mi-raysat_3dsmax2013_64
sc stop LMS
sc stop jhi_service
sc stop "Intel(R) Capability Licensing Service Interface"
:: IT SEEMS that one of the following services, as of 09/25/2017, causes explorer.exe to hang when you attempt to delete a junction; as stopping all the following services eliminates the problem:
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
sc stop AGMService
sc stop SwitchBoard
sc stop AdobeUpdateService
sc stop "Bonjour Service"
sc stop MMCSS
sc stop sppsvc
sc stop TabletInputService
sc stop gupdate
:: SC DELETE gupdate
sc stop BrYNSvc
sc stop bthserv
sc stop "AMD External Events Utility"
sc stop WerSvc
sc stop BEService
sc DELETE BEService
process -k ducservice
process -k amdacpusrsvc
process -k sizer.exe
process -k iexplore.exe
process -k dropbox.exe
process -k DropboxUpdate.exe
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
process -k amdow.exe
process -k sqlwriter.exe
:: Adobe CC-related processes:
process -k "Adobe Desktop Service.exe"
process -k AdobeICPbroker.exe
process -k CoreSync.exe
process -k CCXprocess.exe
process -k CCLibrary.exe
process -k "Adobe CEF Helper.exe"
process -k upd.exe
process -k keybase.exe
process -k jusched.exe
process -k cnext.exe