:: TURN INTO ".BAT" TO USE.
:: ANY FALSE USE OF THIS PROGRAM CAN RESULT IN COPYRIGHT INFRINGEMENT TO THE RESPECTIVE AUTHORS.
@echo off
title VOSVIDEODOWNLOAD
set "VERSION=1.02.50"
set "VERSION_TYPE=DEVELOPMENT"
set "UPDATE_URL=https://raw.githubusercontent.com/vrederik123/VOSVideoDownload/main/VOSVideoDownload/vosvideodownload.bat"
:: MAXIMIZE ACTIVE TERMINAL WINDOW ON LAUNCH
powershell -NoProfile -Command "$ws=Add-Type -MemberDefinition '[DllImport(\"user32.dll\")]public static extern IntPtr GetForegroundWindow();[DllImport(\"user32.dll\")]public static extern bool ShowWindow(IntPtr h,int n);' -Name W -Namespace N -PassThru;$null=$ws::ShowWindow($ws::GetForegroundWindow(),3)" >nul 2>&1

:init
:: LOAD LOCAL DEPENDENCIES PATH, ANSI COLORS, AND SETTINGS.TXT
set "PATH=%~dp0DEPENDENCIES;%PATH%"
for /f "delims=" %%A in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%A"
set "RED=%ESC%[91m"&set "DARKRED=%ESC%[31m"&set "ORANGE=%ESC%[38;5;208m"&set "YELLOW=%ESC%[93m"&set "GREEN=%ESC%[92m"&set "CYAN=%ESC%[96m"&set "RESET=%ESC%[0m"
if not exist "%~dp0settings.txt" echo METADATA=DISABLED> "%~dp0settings.txt"
set "METADATA=DISABLED"
for /f "usebackq tokens=1,2 delims==" %%A in ("%~dp0settings.txt") do if /i "%%A"=="METADATA" set "METADATA=%%B"

:menu
call :banner
echo %RED%WELCOME TO VOSVIDEODOWNLOAD - THE GO-TO VIDEO DOWNLOADER%RESET%
echo %GREEN%1: DOWNLOAD VIDEO%RESET%
echo %GREEN%2: DEPENDENCIES%RESET%
echo %GREEN%3: VOSVIDEODOWNLOAD SETTINGS%RESET%
echo %GREEN%4: QUIT%RESET%
echo %GREEN%5: RESTART%RESET%
echo %GREEN%6: UPDATE VOSVIDEODOWNLOAD%RESET%
set "c="&set /p "c="
if "%c%"=="1" goto download_menu
if "%c%"=="2" goto dependencies
if "%c%"=="3" goto settings
if "%c%"=="4" exit
if "%c%"=="5" goto init
if "%c%"=="6" goto update
goto menu

:download_menu
call :banner
echo %RED%DOWNLOAD OPTIONS%RESET%
echo %GREEN%1: DOWNLOAD VIDEO%RESET%
echo %GREEN%2: DOWNLOAD AUDIO%RESET%
echo %GREEN%3: DOWNLOAD VIDEO ONLY (NO AUDIO)%RESET%
echo %GREEN%4: DOWNLOAD ALL VIDEOS ON CHANNEL%RESET%
echo %GREEN%5: DOWNLOAD ALL SHORTS ON CHANNEL%RESET%
echo %CYAN%ENTER: BACK TO MAIN MENU%RESET%
set "m="&set /p "m="
if "%m%"=="" goto menu
set "P="&set "S="
if "%m%"=="1" (set "P=PASTE VIDEO URL"&set "A=-f "bv*[vcodec^=avc1]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4")
if "%m%"=="2" (set "P=PASTE URL FOR AUDIO"&set "A=-x --audio-format mp3 --audio-quality 0")
if "%m%"=="3" (set "P=PASTE URL FOR VIDEO ONLY"&set "A=-f "bv*[vcodec^=avc1]/bv*[ext=mp4]" --merge-output-format mp4")
if "%m%"=="4" (set "P=PASTE CHANNEL /VIDEOS URL"&set "A=-f "bv*[vcodec^=avc1]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4"&set "S=%%(channel)s - VIDEOS/")
if "%m%"=="5" (set "P=PASTE CHANNEL /SHORTS URL"&set "A=-f "bv*[vcodec^=avc1]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4"&set "S=%%(channel)s - SHORTS/")
if "%P%"=="" goto download_menu
call :banner
set "url="&set /p "url=%RED%%P% %CYAN%(OR PRESS ENTER TO GO BACK)%RED%: %RESET%"
if "%url%"=="" goto download_menu
:: SAVE TO TITLE SUBFOLDER WITH DESCRIPTION + JPG THUMBNAIL WHEN METADATA IS ENABLED
if /i "%METADATA%"=="ENABLED" (
    "%~dp0DEPENDENCIES\yt-dlp.exe" --ffmpeg-location "%~dp0DEPENDENCIES" -P "%~dp0VIDEOS" -o "%S%%%(title)s/%%(title)s.%%(ext)s" %A% --write-description --write-thumbnail --convert-thumbnails jpg "%url%"
) else (
    "%~dp0DEPENDENCIES\yt-dlp.exe" --ffmpeg-location "%~dp0DEPENDENCIES" -P "%~dp0VIDEOS" -o "%S%%%(title)s.%%(ext)s" %A% "%url%"
)
echo.&echo %GREEN%DONE! SAVED TO THE VIDEOS FOLDER.%RESET%
set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
goto download_menu

:update
call :banner
echo %RED%CHECKING FOR VOSVIDEODOWNLOAD UPDATES...%RESET%
set "updateFile=%TEMP%\VOSVideoDownload-latest-%RANDOM%.bat"
set "updateHelper=%TEMP%\VOSVideoDownload-update-%RANDOM%.bat"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Invoke-WebRequest -UseBasicParsing -Uri '%UPDATE_URL%' -OutFile '%updateFile%'" >nul 2>&1
if not exist "%updateFile%" (
    echo %RED%UNABLE TO DOWNLOAD THE UPDATE. CHECK THE UPDATE URL AND YOUR INTERNET CONNECTION.%RESET%
    set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
    goto menu
)
set "remoteVersion="
for /f "delims=" %%A in ('powershell -NoProfile -Command "$content=Get-Content -Raw -LiteralPath '%updateFile%'; if ($content -match 'VERSION=([0-9]+(?:\.[0-9]+)*)') { $matches[1] }"') do set "remoteVersion=%%A"
if "%remoteVersion%"=="" (
    del /f /q "%updateFile%" >nul 2>&1
    echo %RED%THE DOWNLOADED UPDATE DOES NOT CONTAIN A VALID VERSION.%RESET%
    set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
    goto menu
)
set "currentVersion="
for /f "delims=" %%A in ('powershell -NoProfile -Command "$content='%VERSION%'; if ($content -match '^[0-9]+(?:\.[0-9]+)*') { $matches[0] }"') do set "currentVersion=%%A"
for /f "delims=" %%A in ('powershell -NoProfile -Command "try { [version]$new=[version]'%remoteVersion%'; [version]$old=[version]'%currentVersion%'; if ($new -gt $old) { 'NEW' } else { 'CURRENT' } } catch { 'INVALID' }"') do set "updateStatus=%%A"
if "%updateStatus%"=="INVALID" (
    del /f /q "%updateFile%" >nul 2>&1
    echo %RED%THE UPDATE VERSION IS INVALID.%RESET%
    set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
    goto menu
)
if "%updateStatus%"=="CURRENT" (
    del /f /q "%updateFile%" >nul 2>&1
    echo %GREEN%VOSVIDEODOWNLOAD %currentVersion% IS ALREADY UP TO DATE.%RESET%
    set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
    goto menu
)
echo %GREEN%UPDATE FOUND: %currentVersion% TO %remoteVersion%%RESET%
echo %YELLOW%THE PROGRAM WILL RESTART AFTER UPDATING.%RESET%
(
    echo @echo off
    echo timeout /t 2 /nobreak ^>nul
    echo copy /y "%updateFile%" "%~f0" ^>nul
    echo del /f /q "%updateFile%" ^>nul 2^>^&1
    echo start "" "%~f0"
    echo del /f /q "%%~f0" ^>nul 2^>^&1
) > "%updateHelper%"
start "" /b cmd /c "%updateHelper%"
exit

:dependencies
call :banner
echo %RED%DEPENDENCIES%RESET%
echo %GREEN%1: CHECK IF DEPENDENCIES ARE DOWNLOADED%RESET%
echo %GREEN%2: DOWNLOAD DEPENDENCIES%RESET%
echo %GREEN%3: UPDATE DEPENDENCIES%RESET%
echo %GREEN%4: DELETE DEPENDENCIES%RESET%
echo %CYAN%ENTER: BACK TO MAIN MENU%RESET%
set "dc="&set /p "dc="
if "%dc%"=="" goto menu
if "%dc%"=="1" goto dep_check
if "%dc%"=="2" goto dep_dl
if "%dc%"=="3" goto dep_up
if "%dc%"=="4" goto dep_del
goto dependencies

:dep_check
call :banner
set "miss=0"
for %%D in (yt-dlp ffmpeg ffprobe ffplay) do if exist "%~dp0DEPENDENCIES\%%D.exe" (echo %GREEN%[OK] %%D IS INSTALLED.%RESET%) else (echo %RED%[MISSING] %%D IS NOT INSTALLED.%RESET%&set "miss=1")
echo.
if "%miss%"=="1" (
    echo %RED%WOULD YOU LIKE TO INSTALL THE REQUIRED DEPENDENCIES?%RESET%
    echo %GREEN%[Y] YES ^| [N] NO%RESET%
    set "yn="&set /p "yn="
    if /i "%yn%"=="Y" goto dep_dl
    goto dependencies
)
echo %GREEN%ALL DEPENDENCIES ARE WORKING PROPERLY!%RESET%
set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
goto dependencies

:dep_dl
call :banner
if not exist "%~dp0DEPENDENCIES" mkdir "%~dp0DEPENDENCIES"
echo %RED%INSTALLING YT-DLP, FFMPEG, FFPROBE, AND FFPLAY...%RESET%
:: INSTALL LOCALLY AND FLATTEN FFMPEG BINARIES INTO DEPENDENCIES ROOT
for %%P in (yt-dlp.yt-dlp Gyan.FFmpeg) do winget install --id %%P -e --location "%~dp0DEPENDENCIES" --accept-source-agreements --accept-package-agreements
for /r "%~dp0DEPENDENCIES" %%F in (ffmpeg.exe ffprobe.exe ffplay.exe) do move /y "%%F" "%~dp0DEPENDENCIES\" >nul 2>&1
echo.&echo %GREEN%INSTALLATION COMPLETE! INSTALLED TO: %~dp0DEPENDENCIES%RESET%&echo.
set /p "e=%CYAN%ENTER TO RESTART & CONTINUE%RESET%"
start "" "%~f0"
timeout /t 1 /nobreak >nul
exit

:dep_up
call :banner
echo %RED%UPDATING YT-DLP, FFMPEG, FFPROBE, AND FFPLAY...%RESET%
for %%P in (yt-dlp.yt-dlp Gyan.FFmpeg) do winget upgrade --id %%P -e --location "%~dp0DEPENDENCIES" --accept-source-agreements --accept-package-agreements
for /r "%~dp0DEPENDENCIES" %%F in (ffmpeg.exe ffprobe.exe ffplay.exe) do move /y "%%F" "%~dp0DEPENDENCIES\" >nul 2>&1
echo.&echo %GREEN%UPDATE CHECK COMPLETE!%RESET%
set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
goto dependencies

:dep_del
call :banner
echo %RED%WHICH WOULD YOU LIKE TO UNINSTALL?%RESET%
echo %GREEN%1: YT-DLP%RESET%
echo %GREEN%2: FFMPEG (FFMPEG, FFPROBE, FFPLAY)%RESET%
echo %GREEN%3: FFPROBE ONLY%RESET%
echo %GREEN%4: FFPLAY ONLY%RESET%
echo %GREEN%5: ALL%RESET%
echo %CYAN%ENTER: GO BACK%RESET%
set "x="&set /p "x="
if "%x%"=="" goto dependencies
call :banner
if "%x%"=="1" (echo %RED%UNINSTALLING YT-DLP...%RESET%&winget uninstall --id yt-dlp.yt-dlp -e --accept-source-agreements >nul 2>&1&del /f /q "%~dp0DEPENDENCIES\yt-dlp.exe" >nul 2>&1&echo %GREEN%YT-DLP REMOVED.%RESET%)
if "%x%"=="2" (echo %RED%UNINSTALLING FFMPEG SUITE...%RESET%&winget uninstall --id Gyan.FFmpeg -e --accept-source-agreements >nul 2>&1&del /f /q "%~dp0DEPENDENCIES\ff*.exe" >nul 2>&1&for /d %%D in ("%~dp0DEPENDENCIES\ffmpeg*") do rmdir /s /q "%%D"&echo %GREEN%FFMPEG, FFPROBE, AND FFPLAY REMOVED.%RESET%)
if "%x%"=="3" (echo %RED%REMOVING FFPROBE...%RESET%&del /f /q "%~dp0DEPENDENCIES\ffprobe.exe" >nul 2>&1&echo %GREEN%FFPROBE REMOVED.%RESET%)
if "%x%"=="4" (echo %RED%REMOVING FFPLAY...%RESET%&del /f /q "%~dp0DEPENDENCIES\ffplay.exe" >nul 2>&1&echo %GREEN%FFPLAY REMOVED.%RESET%)
if "%x%"=="5" (echo %RED%UNINSTALLING ALL DEPENDENCIES...%RESET%&for %%P in (yt-dlp.yt-dlp Gyan.FFmpeg) do winget uninstall --id %%P -e --accept-source-agreements >nul 2>&1&rmdir /s /q "%~dp0DEPENDENCIES" >nul 2>&1&echo %GREEN%ALL LOCAL DEPENDENCIES REMOVED.%RESET%)
set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
goto dependencies

:settings
call :banner
for %%D in (yt-dlp ffmpeg ffprobe ffplay) do if exist "%~dp0DEPENDENCIES\%%D.exe" (set "st_%%D=%YELLOW%INSTALLED") else (set "st_%%D=%RED%NOT INSTALLED")
set "vc=0"
if exist "%~dp0VIDEOS\*" for /f %%A in ('dir /b /s /a-d "%~dp0VIDEOS\*.mp4" "%~dp0VIDEOS\*.mp3" 2^>nul ^| find /c /v ""') do set "vc=%%A"
echo %RED%VOSVIDEODOWNLOAD SETTINGS%RESET%
echo %GREEN%VERSION: %YELLOW%%VERSION% ^| %VERSION_TYPE%%RESET%
echo %GREEN%INTENDED OPERATING SYSTEM: %YELLOW%WINDOWS11/PC%RESET%
echo %GREEN%DEPENDENCIES:%RESET%
echo %GREEN% - YT-DLP: %st_yt-dlp%%RESET%
echo %GREEN% - FFMPEG: %st_ffmpeg%%RESET%
echo %GREEN% - FFPROBE: %st_ffprobe%%RESET%
echo %GREEN% - FFPLAY: %st_ffplay%%RESET%
echo %GREEN%VIDEOS DOWNLOADED: %YELLOW%%vc%%RESET%&echo.
echo %GREEN%1: TOGGLE METADATA/THUMBNAIL: %YELLOW%%METADATA%%RESET%
echo %CYAN%ENTER: BACK TO MAIN MENU%RESET%
set "sc="&set /p "sc="
if "%sc%"=="" goto menu
if "%sc%"=="1" (if /i "%METADATA%"=="DISABLED" (set "METADATA=ENABLED"&echo METADATA=ENABLED> "%~dp0settings.txt") else (set "METADATA=DISABLED"&echo METADATA=DISABLED> "%~dp0settings.txt"))
goto settings

:banner
cls
:: ESCAPE PIPE CHARACTERS (^|) IN ASCII ART TO PREVENT BATCH SYNTAX ERRORS
echo %DARKRED% __     __   ___    ____     __     __  ___   ____    _____    ___  %RESET%
echo %DARKRED% \ \   / /  / _ \  / ___^|    \ \   / / ^|_ _^| ^|  _ \  ^| ____^|  / _ \ %RESET%
echo %RED%  \ \ / /  ^| ^| ^| ^| \___ \     \ \ / /   ^| ^|  ^| ^| ^| ^| ^|  _^|   ^| ^| ^| ^|%RESET%
echo %RED%   \ V /   ^| ^|_^| ^|  ___) ^|     \ V /    ^| ^|  ^| ^|_^| ^| ^| ^|___  ^| ^|_^| ^|%RESET%
echo %ORANGE%    \_/     \___/  ^|____/       \_/    ^|___^| ^|____/  ^|_____^|  \___/ %RESET%
echo %ORANGE%  ____     ___   __        __  _   _   _        ___      _     ____  %RESET%
echo %ORANGE% ^|  _ \   / _ \  \ \      / / ^| \ ^| ^| ^| ^|      / _ \    / \   ^|  _ \ %RESET%
echo %ORANGE% ^| ^| ^| ^| ^| ^| ^| ^|  \ \ /\ / /  ^|  \^| ^| ^| ^|     ^| ^| ^| ^|  / _ \  ^| ^| ^| ^|%RESET%
echo %YELLOW% ^| ^|_^| ^| ^| ^|_^| ^|   \ V  V /   ^| ^|\  ^| ^| ^|___  ^| ^|_^| ^| / ___ \ ^| ^|_^| ^|%RESET%
echo %YELLOW% ^|____/   \___/     \_/\_/    ^|_^| \_^| ^|_____^|  \___/ /_/   \_\^|____/ %RESET%
echo.
goto :eof
