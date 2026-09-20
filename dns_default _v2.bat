@echo off
:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

cls
echo =======================================================
echo   Resetting DNS to Automatic (DHCP)
echo   (Physical Adapters Only - All States)
echo =======================================================
echo.

:: Apply via PowerShell to reset IPv4 and IPv6 to automatic on physical adapters
echo Resetting DNS configuration on physical Ethernet and Wi-Fi adapters...
powershell -NoProfile -Command "$adapters = Get-NetAdapter -Physical | Where-Object {$_.Name -like '*Ethernet*' -or $_.Name -like '*Wi-Fi*'}; foreach ($adapter in $adapters) { Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses }"

echo.
echo DNS settings have been reset to automatic!
echo Flushing DNS cache...
ipconfig /flushdns

echo.
echo Done! Press any key to exit.
pause >nul