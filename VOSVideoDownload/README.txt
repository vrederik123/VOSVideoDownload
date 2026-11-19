ANY FALSE USE OF THIS PROGRAM CAN RESULT IN COPYRIGHT INFRINGEMENT TO THE RESPECTIVE AUTHORS.
THIS CODE HAS BEEN WRITTEN WITH THE USE OF ARTIFICIAL INTELLIGENCE.

INSTALLING:

STEP 1:
MAKE A !NEW! .TXT DOCUMENT

STEP 2:
COPY THE FOLLOWING SCRIPT:
"ANY FALSE USE OF THIS PROGRAM CAN RESULT IN COPYRIGHT INFRINGEMENT TO THE RESPECTIVE AUTHORS.
THIS CODE HAS BEEN WRITTEN WITH THE USE OF ARTIFICIAL INTELLIGENCE.

INSTALLING:

STEP 1:
MAKE A !NEW! .TXT DOCUMENT

STEP 2:
COPY THE FOLLOWING SCRIPT:
"@echo off
setlocal
title VOSVIDEODOWNLOAD INSTALLER

set "INSTALL_URL=https://raw.githubusercontent.com/vrederik123/VOSVideoDownload---Updates/main/vosvideodownload.bat"
set "installFile=%TEMP%\VOSVideoDownload-install-%RANDOM%-%RANDOM%.bat"
set "installPath=%~dp0vosvideodownload.bat"
set "VOS_INSTALL_FILE=%installFile%"
set "VOS_INSTALL_URL=%INSTALL_URL%?cache=%RANDOM%%RANDOM%"

for /f "delims=" %%A in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%A"
set "RESET=%ESC%[0m"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "CYAN=%ESC%[96m"
set "FLAME1=%ESC%[38;2;120;0;0m"
set "FLAME2=%ESC%[38;2;155;0;0m"
set "FLAME3=%ESC%[38;2;190;5;0m"
set "FLAME4=%ESC%[38;2;225;20;0m"
set "FLAME5=%ESC%[38;2;250;45;0m"
set "FLAME6=%ESC%[38;2;255;80;0m"
set "FLAME7=%ESC%[38;2;255;120;0m"
set "FLAME8=%ESC%[38;2;255;165;0m"
set "FLAME9=%ESC%[38;2;255;205;0m"
set "FLAME10=%ESC%[38;2;255;240;75m"

call :banner
echo %CYAN%DO YOU WANT TO INSTALL VOSVIDEODOWNLOAD?%RESET%
echo %CYAN%[Y] YES [N] NO%RESET%
choice /c YN /n
if errorlevel 2 exit
if errorlevel 1 goto install
exit

:install
call :banner
echo %CYAN%DOWNLOADING VOSVIDEODOWNLOAD...%RESET%
where curl.exe >nul 2>&1
if errorlevel 1 goto install_powershell
curl.exe --location --fail --silent --show-error --connect-timeout 10 --max-time 60 "%VOS_INSTALL_URL%" --output "%installFile%"
if errorlevel 1 goto download_failed
goto validate_download

:install_powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $request=[System.Net.HttpWebRequest]::Create($env:VOS_INSTALL_URL); $request.Timeout=60000; $request.ReadWriteTimeout=60000; $response=$request.GetResponse(); try { $stream=$response.GetResponseStream(); $file=[System.IO.File]::Create($env:VOS_INSTALL_FILE); try { $stream.CopyTo($file) } finally { $file.Dispose(); $stream.Dispose() } } finally { $response.Dispose() }"
if errorlevel 1 goto download_failed

:validate_download
if not exist "%installFile%" goto invalid_download
for %%A in ("%installFile%") do if %%~zA LSS 100 goto invalid_download
set "installedVersion="
for /f "delims=" %%A in ('powershell -NoProfile -Command "$content=Get-Content -Raw -LiteralPath $env:VOS_INSTALL_FILE; if ($content -match 'VERSION=([0-9]+(?:\.[0-9]+)*)') { $matches[1] }"') do set "installedVersion=%%A"
if "%installedVersion%"=="" goto invalid_download

powershell -NoProfile -Command "$p=$env:VOS_INSTALL_FILE; $content=[System.IO.File]::ReadAllText($p); $pattern='(?m)set \x22UPDATE_URL=[^\r\n]*'; $found=[regex]::Matches($content,$pattern); if($found.Count -ne 1){throw 'The update URL setting is missing or duplicated'}; $line='set '+[char]34+'UPDATE_URL=https://raw.githubusercontent.com/vrederik123/VOSVideoDownload---Updates/main/vosvideodownload.bat'+[char]34; $content=[regex]::Replace($content,$pattern,$line); [System.IO.File]::WriteAllText($p,$content,(New-Object System.Text.UTF8Encoding($false)))"
if errorlevel 1 goto invalid_download

copy /y "%installFile%" "%installPath%" >nul
if errorlevel 1 goto install_failed
del /f /q "%installFile%" >nul 2>&1
call :banner
echo %GREEN%VOSVIDEODOWNLOAD %installedVersion% INSTALLED SUCCESSFULLY.%RESET%
echo %CYAN%STARTING VOSVIDEODOWNLOAD...%RESET%
start "" "%installPath%"
exit

:download_failed
echo %RED%DOWNLOAD FAILED. CHECK YOUR INTERNET CONNECTION AND TRY AGAIN.%RESET%
goto failed

:invalid_download
echo %RED%THE DOWNLOADED FILE IS NOT A VALID VOSVIDEODOWNLOAD PROGRAM.%RESET%
goto failed

:install_failed
echo %RED%INSTALL FAILED. COULD NOT WRITE TO "%installPath%". CHECK FOLDER PERMISSIONS.%RESET%

:failed
if exist "%installFile%" del /f /q "%installFile%" >nul 2>&1
pause
exit /b 1

:banner
cls
echo %FLAME1% __     __   ___    ____     __     __  ___   ____    _____    ___  %RESET%
echo %FLAME2% \ \   / /  / _ \  / ___^|    \ \   / / ^|_ _^| ^|  _ \  ^| ____^|  / _ \ %RESET%
echo %FLAME3%  \ \ / /  ^| ^| ^| ^| \___ \     \ \ / /   ^| ^|  ^| ^| ^| ^| ^|  _^|   ^| ^| ^| ^|%RESET%
echo %FLAME4%   \ V /   ^| ^|_^| ^|  ___) ^|     \ V /    ^| ^|  ^| ^|_^| ^| ^| ^|___  ^| ^|_^| ^|%RESET%
echo %FLAME5%    \_/     \___/  ^|____/       \_/    ^|___^| ^|____/  ^|_____^|  \___/ %RESET%
echo %FLAME6%  ____     ___   __        __  _   _   _        ___      _     ____  %RESET%
echo %FLAME7% ^|  _ \   / _ \  \ \      / / ^| \ ^| ^| ^| ^|      / _ \    / \   ^|  _ \ %RESET%
echo %FLAME8% ^| ^| ^| ^| ^| ^| ^| ^|  \ \ /\ / /  ^|  \^| ^| ^| ^|     ^| ^| ^| ^|  / _ \  ^| ^| ^| ^|%RESET%
echo %FLAME9% ^| ^|_^| ^| ^| ^|_^| ^|   \ V  V /   ^| ^|\  ^| ^| ^|___  ^| ^|_^| ^| / ___ \ ^| ^|_^| ^|%RESET%
echo %FLAME10% ^|____/   \___/     \_/\_/    ^|_^| \_^| ^|_____^|  \___/ /_/   \_\^|____/ %RESET%
echo.
goto :eof"

! - DO NOT INCLUDE THE QUATATION MARKS (THESE > "")

STEP 3:
SAVE THE FILE (COMMAND + S)

STEP 4:
SAVE AS .BAT


* DUE TO FREQUENTLY USED AS A WAY OF SPREADING MALWARE, MICROSOFT SMART APPS WILL BLOCK ANY .BAT FILE COMING FROM A PREINSTALLED DOCUMENT."

! - DO NOT INCLUDE THE QUATATION MARKS (THESE > "")

STEP 3:
SAVE THE FILE (COMMAND + S)

STEP 4:
SAVE AS .BAT


* DUE TO FREQUENTLY USED AS A WAY OF SPREADING MALWARE, MICROSOFT SMART APPS WILL BLOCK ANY .BAT FILE COMING FROM A PREINSTALLED DOCUMENT.
