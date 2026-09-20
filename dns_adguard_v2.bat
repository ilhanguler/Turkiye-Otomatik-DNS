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
echo   Configuring AdGuard DNS and DoH (IPv4/IPv6)
echo   (Physical Adapters Only - All States)
echo =======================================================
echo.

set "TEMPLATE=https://dns.adguard-dns.com/dns-query"

:: 1. Add/Set the Encryption Template for AdGuard IPv4
echo Configuring IPv4 DoH templates...
netsh dns add encryption server=94.140.14.14 dohtemplate=%TEMPLATE% autoupgrade=yes udpfallback=no >nul 2>&1
netsh dns set encryption server=94.140.14.14 dohtemplate=%TEMPLATE% autoupgrade=yes udpfallback=no >nul 2>&1
netsh dns add encryption server=94.140.15.15 dohtemplate=%TEMPLATE% autoupgrade=yes udpfallback=no >nul 2>&1
netsh dns set encryption server=94.140.15.15 dohtemplate=%TEMPLATE% autoupgrade=yes udpfallback=no >nul 2>&1

:: 2. Add/Set the Encryption Template for AdGuard IPv6 (Corrected with :ff)
echo Configuring IPv6 DoH templates...
netsh dns add encryption server=2a10:50c0::ad1:ff dohtemplate=%TEMPLATE% autoupgrade=yes udpfallback=no >nul 2>&1
netsh dns set encryption server=2a10:50c0::ad1:ff dohtemplate=%TEMPLATE% autoupgrade=yes udpfallback=no >nul 2>&1
netsh dns add encryption server=2a10:50c0::ad2:ff dohtemplate=%TEMPLATE% autoupgrade=yes udpfallback=no >nul 2>&1
netsh dns set encryption server=2a10:50c0::ad2:ff dohtemplate=%TEMPLATE% autoupgrade=yes udpfallback=no >nul 2>&1

:: 3. Apply via PowerShell to Physical Adapters Only (Regardless of ON/OFF state)
echo Applying DNS to physical Ethernet and Wi-Fi adapters...
powershell -NoProfile -Command "$adapters = Get-NetAdapter -Physical | Where-Object {$_.Name -like '*Ethernet*' -or $_.Name -like '*Wi-Fi*'}; foreach ($adapter in $adapters) { Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses '94.140.14.14','94.140.15.15','2a10:50c0::ad1:ff','2a10:50c0::ad2:ff' }"

echo.
echo Settings applied.
echo Flushing DNS cache...
ipconfig /flushdns

echo.
echo Done! Press any key to exit.
pause >nul