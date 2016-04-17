FIX THE FOLLOWING TO WORK:

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
SC CONFIG "DPS" DEMAND
SC CONFIG "FontCache" DEMAND
SC CONFIG "WPCSvc" DEMAND
SC CONFIG "ehRecvr" DEMAND
SC CONFIG "ehSched" DEMAND
SC CONFIG "WMPNetworkSvc" DEMAND
SC CONFIG "HomeGroupProvider" DEMAND
SC CONFIG "HomeGroupListener" DEMAND
SC CONFIG "TabletInputService" DEMAND
SC CONFIG "wscsvc" DEMAND
SC CONFIG "WinDefend" DEMAND
SC CONFIG "WMPNetworkSvc" DEMAND
SC CONFIG "WinRM" DEMAND
SC CONFIG "Mcx2Svc" DEMAND
SC CONFIG "CscService" DEMAND
SC CONFIG "AeLookupSvc" DEMAND
SC STOP gusvc
SC DELETE gusvc
SC STOP gupdate
SC DELETE gupdate