REM DESCRIPTION
REM Sets services to states which I prefer for not wasteroo ridiculous process hogging on Windows 8+ computers.

REM REVISION HISTORY
REM BEFORE NOW: yesh.
REM 2016-08-31 corrected syntax; I don't know how long this hasn't been working :p

sc stop "SharedAccess"
sc stop "ehRecvr"
sc stop "ehSched"
sc stop "DPS"
sc stop "FontCache"
sc stop "WPCSvc"
sc stop "ehRecvr"
sc stop "ehSched"
sc stop "WMPNetworkSvc"
sc stop "HomeGroupProvider"
sc stop "HomeGroupListener"
sc stop "TabletInputService"
sc stop "wscsvc"
sc stop "WinDefend"
sc stop "WMPNetworkSvc"
sc stop "WinRM"
sc stop "Mcx2Svc"
sc stop "CscService"
sc stop "AeLookupSvc"
sc stop "NgcSvc"
sc stop "NgcCtnrSvc"
sc stop "tiledatamodelsvc"
sc stop "Themes"
sc stop "LicenseManager"
sc stop "DoSvc"
sc stop "DiagTrack"
sc stop "BITS"
sc stop "StorSvc"
sc config "SharedAccess" start= demand
sc config "ehRecvr" start= demand
sc config "ehSched" start= demand
sc config "DPS" start= demand
sc config "FontCache" start= demand
sc config "WPCSvc" start= demand
sc config "ehRecvr" start= demand
sc config "ehSched" start= demand
sc config "WMPNetworkSvc" start= demand
sc config "HomeGroupProvider" start= demand
sc config "HomeGroupListener" start= demand
sc config "TabletInputService" start= demand
sc config "wscsvc" start= demand
sc config "WinDefend" start= demand
sc config "WMPNetworkSvc" start= demand
sc config "WinRM" start= demand
sc config "Mcx2Svc" start= demand
sc config "CscService" start= demand
sc config "AeLookupSvc" start= demand
sc config "NgcSvc" start= disabled
sc config "NgcCtnrSvc" start= disabled
sc config "tiledatamodelsvc" start= disabled
sc config "Themes" start= disabled
sc config "LicenseManager" start= disabled
sc config "DoSvc" start= disabled
sc config "DiagTrack" start= disabled
sc config "BITS" start= disabled
sc config "StorSvc" start= disabled
sc stop gusvc
sc delete gusvc
sc stop gupdate
sc delete gupdate