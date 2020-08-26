:: DESCRIPTION
:: Prints the enabled network adapter speed.

:: USAGE
:: Run without any parameters:
::    get_windows_network_enabled_adapter_speed.bat


:: CODE
:: re: https://www.windowscentral.com/how-determine-wi-fi-and-ethernet-connection-speed-windows-10
wmic nic where netEnabled=true get name, speed