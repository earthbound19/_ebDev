SC STOP "DPS"
SC STOP "FontCache"
SC STOP "WPCSvc"
SC STOP "ehRecvr"
SC STOP "ehSched"
SC STOP "WMPNetworkSvc"
SC STOP "HomeGroupProvider"
SC STOP "HomeGroupListener"
SC STOP "TabletInputService"
SC STOP "wscsvc"
SC STOP "WinDefend"
SC STOP "WMPNetworkSvc"
SC STOP "WinRM"
SC STOP "Mcx2Svc"
SC STOP "CscService"
SC STOP "AeLookupSvc"
SC STOP "Themes"
SC STOP "PcaSvc"
SC STOP "WSearch"
SC STOP "wuauserv"
SC STOP "TabletInputService"
SC STOP "Fax"
SC CONFIG "DPS" start= DEMAND
SC CONFIG "FontCache" start= DEMAND
SC CONFIG "WPCSvc" start= DEMAND
SC CONFIG "ehRecvr" start= DEMAND
SC CONFIG "ehSched" start= DEMAND
SC CONFIG "WMPNetworkSvc" start= DEMAND
SC CONFIG "HomeGroupProvider" start= DEMAND
SC CONFIG "HomeGroupListener" start= DEMAND
SC CONFIG "TabletInputService" start= DEMAND
SC CONFIG "wscsvc" start= DEMAND
SC CONFIG "WinDefend" start= DEMAND
SC CONFIG "WMPNetworkSvc" start= DEMAND
SC CONFIG "WinRM" start= DEMAND
SC CONFIG "Mcx2Svc" start= DEMAND
SC CONFIG "CscService" start= DEMAND
SC CONFIG "AeLookupSvc" start= DEMAND
SC CONFIG "Themes" start= DISABLED
SC CONFIG "PcaSvc" start= DEMAND
SC CONFIG "WSearch" start= DISABLED
SC CONFIG "wuauserv" start= DISABLED
SC CONFIG "TabletInputService" start= DISABLED
SC CONFIG "Fax" start= DEMAND
SC STOP gusvc
SC DELETE gusvc
SC STOP gupdate
SC DELETE gupdate