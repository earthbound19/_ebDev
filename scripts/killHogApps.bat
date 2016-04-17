REM TO DO: Find the exact name of the FlashP* / FlashU* executables and use the found name to terminate those.
sc stop Everything
sc stop DisplayFusionService
sc stop "Bonjour Service"
sc stop "iPod Service"
sc stop "Apple Mobile Device Service"
sc stop SbieSvc
sc stop PcaSvc
sc stop AeLookupSvc
sc stop MBAMScheduler
sc stop wscsvc
sc stop mi-raysat_3dsmax2013_64
sc stop LMS
sc stop jhi_service
sc stop "Intel(R) Capability Licensing Service Interface"
process -k dropbox.exe
process -k greenshot.exe
process -k robotaskbaricon.exe
process -k DisplayFusionHookAppWIN6064.exe
process -k DisplayFusionHookAppWIN6032.exe
process -k DisplayFusion.exe
process -k CCC.exe
process -k COCIManager.exe