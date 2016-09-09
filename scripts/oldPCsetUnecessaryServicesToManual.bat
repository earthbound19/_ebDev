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
sc stop "Themes"
sc stop "PcaSvc"
sc stop "WSearch"
sc stop "wuauserv"
sc stop "TabletInputService"
sc stop "Fax"
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
sc config "Themes" start= disabled
sc config "PcaSvc" start= demand
sc config "WSearch" start= disabled
sc config "wuauserv" start= disabled
sc config "TabletInputService" start= disabled
sc config "Fax" start= demand
sc stop gusvc
sc delete gusvc
sc stop gupdate
sc delete gupdate