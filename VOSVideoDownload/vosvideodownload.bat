:: TURN INTO ".BAT" TO USE.
:: ANY FALSE USE OF THIS PROGRAM CAN RESULT IN COPYRIGHT INFRINGEMENT TO THE RESPECTIVE AUTHORS.
@echo off
title VOSVIDEODOWNLOAD
set "VERSION=1.02.90"
set "VERSION_TYPE=DEVELOPMENT"
set "OPERATING_SYSTEM=Windows 11/PC"
set "UPDATE_URL=https://raw.githubusercontent.com/vrederik123/VOSVideoDownload/main/VOSVideoDownload/vosvideodownload.bat"
:: MAXIMIZE ACTIVE TERMINAL WINDOW ON LAUNCH
powershell -NoProfile -Command "$ws=Add-Type -MemberDefinition '[DllImport(\"user32.dll\")]public static extern IntPtr GetForegroundWindow();[DllImport(\"user32.dll\")]public static extern bool ShowWindow(IntPtr h,int n);' -Name W -Namespace N -PassThru;$null=$ws::ShowWindow($ws::GetForegroundWindow(),3)" >nul 2>&1

:init
:: LOAD LOCAL DEPENDENCIES PATH, ANSI COLORS, AND SETTINGS.TXT
set "PATH=%~dp0DEPENDENCIES;%PATH%"
for /f "delims=" %%A in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%A"
set "RED=%ESC%[91m"&set "DARKRED=%ESC%[31m"&set "ORANGE=%ESC%[38;5;208m"&set "YELLOW=%ESC%[93m"&set "GREEN=%ESC%[92m"&set "CYAN=%ESC%[96m"&set "RESET=%ESC%[0m"
set "PURPLE=%ESC%[35m"&set "PINK=%ESC%[95m"&set "WHITE=%ESC%[97m"
if not exist "%~dp0settings.txt" (
    echo METADATA=DISABLED> "%~dp0settings.txt"
    echo FLAME=STANDARD>> "%~dp0settings.txt"
)
set "METADATA=DISABLED"
set "FLAME=STANDARD"
for /f "usebackq tokens=1,2 delims==" %%A in ("%~dp0settings.txt") do (
    if /i "%%A"=="METADATA" set "METADATA=%%B"
    if /i "%%A"=="FLAME" set "FLAME=%%B"
)
call :set_flame

:menu
call :banner
echo %RED%WELCOME TO VOSVIDEODOWNLOAD - THE GO-TO VIDEO DOWNLOADER%RESET%
echo %GREEN%1: DOWNLOAD VIDEO%RESET%
echo %GREEN%2: DEPENDENCIES%RESET%
echo %GREEN%3: UPDATE VOSVIDEODOWNLOAD%RESET%
echo %GREEN%4: VOSVIDEODOWNLOAD SETTINGS%RESET%
echo %GREEN%5: QUIT%RESET%
echo %GREEN%6: RESTART%RESET%
set "c="&set /p "c="
if "%c%"=="1" goto download_menu
if "%c%"=="2" goto dependencies
if "%c%"=="3" goto update
if "%c%"=="4" goto settings
if "%c%"=="5" exit
if "%c%"=="6" goto init
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
set "P="&set "S="&set "A="
if "%m%"=="1" (set "P=PASTE VIDEO URL"&set "A=-f "bv*[vcodec^=avc1]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4")
if "%m%"=="2" (set "P=PASTE URL FOR AUDIO"&set "A=-x --audio-format mp3 --audio-quality 0")
if "%m%"=="3" (set "P=PASTE URL FOR VIDEO ONLY"&set "A=-f "bv*[vcodec^=avc1]/bv*[ext=mp4]" --merge-output-format mp4")
if "%m%"=="4" (set "P=PASTE CHANNEL /VIDEOS URL"&set "A=-f "bv*[vcodec^=avc1]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4"&set "S=%%(channel)s - VIDEOS/")
if "%m%"=="5" (set "P=PASTE CHANNEL /SHORTS URL"&set "A=-f "bv*[vcodec^=avc1]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4"&set "S=%%(channel)s - SHORTS/")
if "%P%"=="" goto download_menu
call :banner
set "url="&set /p "url=%RED%%P% %CYAN%(OR PRESS ENTER TO GO BACK)%RED%: %RESET%"
if "%url%"=="" goto download_menu
if not exist "%~dp0DEPENDENCIES\yt-dlp.exe" (
    echo %RED%YT-DLP IS MISSING. INSTALL DEPENDENCIES FIRST.%RESET%
    set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
    goto download_menu
)
if /i "%METADATA%"=="ENABLED" (
    "%~dp0DEPENDENCIES\yt-dlp.exe" --ffmpeg-location "%~dp0DEPENDENCIES" -P "%~dp0VIDEOS" -o "%S%%%(title)s/%%(title)s.%%(ext)s" %A% --write-description --write-thumbnail --convert-thumbnails jpg "%url%"
) else (
    "%~dp0DEPENDENCIES\yt-dlp.exe" --ffmpeg-location "%~dp0DEPENDENCIES" -P "%~dp0VIDEOS" -o "%S%%%(title)s.%%(ext)s" %A% "%url%"
)
if errorlevel 1 goto download_failed
echo.&echo %GREEN%DONE! SAVED TO THE VIDEOS FOLDER.%RESET%
set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
goto download_menu

:download_failed
echo.&echo %RED%DOWNLOAD FAILED. YT-DLP RETURNED ERROR CODE %ERRORLEVEL%. CHECK THE URL, NETWORK, AND DEPENDENCIES.%RESET%
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
set "currentVersion=%VERSION%"
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
set /p "e=%CYAN%PRESS ENTER TO APPLY THE UPDATE AND RESTART%RESET%"
(
    echo @echo off
    echo timeout /t 2 /nobreak ^>nul
    echo copy /y "%updateFile%" "%~f0" ^>nul
    echo if errorlevel 1 goto cleanup
    echo start "" "%~f0"
    echo :cleanup
    echo del /f /q "%updateFile%" ^>nul 2^>^&1
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
for %%D in (yt-dlp ffmpeg ffprobe ffplay) do call :check_one "%%D"
echo.
if "%miss%"=="1" (
    echo %RED%ONE OR MORE DEPENDENCIES ARE MISSING OR NOT WORKING.%RESET%
    echo %RED%WOULD YOU LIKE TO INSTALL/REPAIR THE DEPENDENCIES?%RESET%
    echo %GREEN%[Y] YES ^| [N] NO%RESET%
    set "yn="&set /p "yn="
    if /i "%yn%"=="Y" goto dep_dl
    goto dependencies
)
echo %GREEN%ALL DEPENDENCIES ARE PRESENT AND RESPONDING.%RESET%
set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
goto dependencies

:check_one
if not exist "%~dp0DEPENDENCIES\%~1.exe" (
    echo %RED%[MISSING] %~1 IS NOT INSTALLED.%RESET%
    set "miss=1"
    exit /b 0
)
"%~dp0DEPENDENCIES\%~1.exe" --version >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR] %~1 EXISTS BUT FAILED TO RUN.%RESET%
    set "miss=1"
) else echo %GREEN%[OK] %~1 IS INSTALLED AND RUNNING.%RESET%
exit /b 0

:dep_dl
call :banner
if not exist "%~dp0DEPENDENCIES" mkdir "%~dp0DEPENDENCIES"
if not exist "%~dp0DEPENDENCIES" (
    echo %RED%COULD NOT CREATE THE DEPENDENCIES FOLDER.%RESET%
    set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
    goto dependencies
)
echo %RED%INSTALLING YT-DLP, FFMPEG, FFPROBE, AND FFPLAY...%RESET%
set "depFailed=0"
for %%P in (yt-dlp.yt-dlp Gyan.FFmpeg) do call :install_package "%%P"
for /r "%~dp0DEPENDENCIES" %%F in (ffmpeg.exe ffprobe.exe ffplay.exe) do if /i not "%%~dpF"=="%~dp0DEPENDENCIES\" move /y "%%F" "%~dp0DEPENDENCIES\" >nul 2>&1
if "%depFailed%"=="1" (
    echo %RED%ONE OR MORE PACKAGES FAILED TO INSTALL. REVIEW THE OUTPUT ABOVE.%RESET%
) else (
    echo %GREEN%INSTALLATION COMMANDS COMPLETED. VERIFY THE FILES WITH OPTION 1.%RESET%
)
echo %GREEN%INSTALL LOCATION: %~dp0DEPENDENCIES%RESET%
set /p "e=%CYAN%PRESS ENTER TO RESTART%RESET%"
start "" "%~f0"
exit

:install_package
winget install --id %~1 -e --location "%~dp0DEPENDENCIES" --accept-source-agreements --accept-package-agreements
if errorlevel 1 set "depFailed=1"
exit /b 0

:dep_up
call :banner
echo %RED%UPDATING YT-DLP, FFMPEG, FFPROBE, AND FFPLAY...%RESET%
set "depFailed=0"
for %%P in (yt-dlp.yt-dlp Gyan.FFmpeg) do call :upgrade_package "%%P"
for /r "%~dp0DEPENDENCIES" %%F in (ffmpeg.exe ffprobe.exe ffplay.exe) do if /i not "%%~dpF"=="%~dp0DEPENDENCIES\" move /y "%%F" "%~dp0DEPENDENCIES\" >nul 2>&1
if "%depFailed%"=="1" (
    echo %RED%ONE OR MORE DEPENDENCY UPDATES FAILED.%RESET%
) else (
    echo %GREEN%UPDATE COMMANDS COMPLETED. VERIFY THE FILES WITH OPTION 1.%RESET%
)
set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
goto dependencies

:upgrade_package
winget upgrade --id %~1 -e --location "%~dp0DEPENDENCIES" --accept-source-agreements --accept-package-agreements
if errorlevel 1 set "depFailed=1"
exit /b 0

:dep_del
call :banner
echo %RED%WHICH LOCAL DEPENDENCY FILES WOULD YOU LIKE TO REMOVE?%RESET%
echo %GREEN%1: YT-DLP%RESET%
echo %GREEN%2: FFMPEG (FFMPEG, FFPROBE, FFPLAY)%RESET%
echo %GREEN%3: FFPROBE ONLY%RESET%
echo %GREEN%4: FFPLAY ONLY%RESET%
echo %GREEN%5: ALL LOCAL DEPENDENCY FILES%RESET%
echo %CYAN%ENTER: GO BACK%RESET%
set "x="&set /p "x="
if "%x%"=="" goto dependencies
if "%x%"=="1" (
    del /f /q "%~dp0DEPENDENCIES\yt-dlp.exe" >nul 2>&1
    echo %GREEN%LOCAL YT-DLP FILE REMOVED IF IT WAS PRESENT. WINGET PACKAGES WERE NOT UNINSTALLED.%RESET%
)
if "%x%"=="2" (
    del /f /q "%~dp0DEPENDENCIES\ffmpeg.exe" "%~dp0DEPENDENCIES\ffprobe.exe" "%~dp0DEPENDENCIES\ffplay.exe" >nul 2>&1
    for /d %%D in ("%~dp0DEPENDENCIES\ffmpeg*") do if exist "%%~fD" rmdir /s /q "%%~fD"
    echo %GREEN%LOCAL FFMPEG FILES REMOVED IF PRESENT. WINGET PACKAGES WERE NOT UNINSTALLED.%RESET%
)
if "%x%"=="3" (
    del /f /q "%~dp0DEPENDENCIES\ffprobe.exe" >nul 2>&1
    echo %GREEN%LOCAL FFPROBE FILE REMOVED IF IT WAS PRESENT.%RESET%
)
if "%x%"=="4" (
    del /f /q "%~dp0DEPENDENCIES\ffplay.exe" >nul 2>&1
    echo %GREEN%LOCAL FFPLAY FILE REMOVED IF IT WAS PRESENT.%RESET%
)
if "%x%"=="5" (
    if exist "%~dp0DEPENDENCIES" rmdir /s /q "%~dp0DEPENDENCIES"
    echo %GREEN%LOCAL DEPENDENCIES FOLDER REMOVED. WINGET PACKAGES WERE NOT UNINSTALLED.%RESET%
)
if not "%x%"=="1" if not "%x%"=="2" if not "%x%"=="3" if not "%x%"=="4" if not "%x%"=="5" goto dependencies
set /p "e=%CYAN%PRESS ENTER TO CONTINUE%RESET%"
goto dependencies

:settings
call :banner
for %%D in (yt-dlp ffmpeg ffprobe ffplay) do if exist "%~dp0DEPENDENCIES\%%D.exe" (set "st_%%D=%YELLOW%INSTALLED") else (set "st_%%D=%RED%NOT INSTALLED")
set "vc=0"
if exist "%~dp0VIDEOS\*" for /f %%A in ('powershell -NoProfile -Command "$p='%~dp0VIDEOS'; if (Test-Path -LiteralPath $p) { (Get-ChildItem -LiteralPath $p -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '^\.(mp4|mp3|mkv|webm|m4a|wav|mov|avi|flv|ogg|opus|aac|wmv)$' } | Measure-Object).Count } else { 0 }"') do set "vc=%%A"
echo %RED%VOSVIDEODOWNLOAD SETTINGS%RESET%
echo %GREEN%VERSION: %YELLOW%%VERSION% ^| %VERSION_TYPE%%RESET%
echo %GREEN%INTENDED OPERATING SYSTEM: %YELLOW%%OPERATING_SYSTEM%%RESET%
echo %GREEN%DEPENDENCIES:%RESET%
echo %GREEN% - YT-DLP: %st_yt-dlp%%RESET%
echo %GREEN% - FFMPEG: %st_ffmpeg%%RESET%
echo %GREEN% - FFPROBE: %st_ffprobe%%RESET%
echo %GREEN% - FFPLAY: %st_ffplay%%RESET%
echo %GREEN%VIDEOS DOWNLOADED: %YELLOW%%vc%%RESET%&echo.
echo %GREEN%SETTINGS%RESET%
echo %GREEN%1: TOGGLE METADATA/THUMBNAIL: %YELLOW%%METADATA%%RESET%
echo %GREEN%2: ASCII FLAME: %YELLOW%%FLAME_DISPLAY%%RESET%
echo %CYAN%ENTER: BACK TO MAIN MENU%RESET%
set "sc="&set /p "sc="
if "%sc%"=="" goto menu
if "%sc%"=="1" (
    if /i "%METADATA%"=="DISABLED" (set "METADATA=ENABLED") else (set "METADATA=DISABLED")
    call :save_settings
)
if "%sc%"=="2" goto flame_settings
goto settings

:flame_settings
call :banner
echo %GREEN%ASCII FLAME SETTINGS%RESET%
echo %GREEN%1: (STANDARD) RED-YELLOW FLAME%RESET%
echo %GREEN%2: PURPLE-PINK FLAME%RESET%
echo %GREEN%3: GREEN-WHITE FLAME%RESET%
echo %GREEN%4: YELLOW-WHITE FLAME%RESET%
echo %CYAN%ENTER: BACK TO SETTINGS%RESET%
set "fc="&set /p "fc="
if "%fc%"=="" goto settings
if "%fc%"=="1" set "FLAME=STANDARD"
if "%fc%"=="2" set "FLAME=PURPLE-PINK"
if "%fc%"=="3" set "FLAME=GREEN-WHITE"
if "%fc%"=="4" set "FLAME=YELLOW-WHITE"
if not "%fc%"=="1" if not "%fc%"=="2" if not "%fc%"=="3" if not "%fc%"=="4" goto flame_settings
call :set_flame
call :save_settings
goto settings

:save_settings
> "%~dp0settings.txt" echo METADATA=%METADATA%
>> "%~dp0settings.txt" echo FLAME=%FLAME%
exit /b

:set_flame
if /i "%FLAME%"=="PURPLE-PINK" (
    set "FLAME_DISPLAY=PURPLE-PINK FLAME"
    set "FLAME1=%PURPLE%"
    set "FLAME2=%PINK%"
    set "FLAME3=%PINK%"
    set "FLAME4=%PINK%"
    exit /b
)
if /i "%FLAME%"=="GREEN-WHITE" (
    set "FLAME_DISPLAY=GREEN-WHITE FLAME"
    set "FLAME1=%ESC%[32m"
    set "FLAME2=%GREEN%"
    set "FLAME3=%WHITE%"
    set "FLAME4=%WHITE%"
    exit /b
)
if /i "%FLAME%"=="YELLOW-WHITE" (
    set "FLAME_DISPLAY=YELLOW-WHITE FLAME"
    set "FLAME1=%ESC%[33m"
    set "FLAME2=%YELLOW%"
    set "FLAME3=%WHITE%"
    set "FLAME4=%WHITE%"
    exit /b
)
set "FLAME=STANDARD"
set "FLAME_DISPLAY=RED-YELLOW FLAME"
set "FLAME1=%DARKRED%"
set "FLAME2=%RED%"
set "FLAME3=%ORANGE%"
set "FLAME4=%YELLOW%"
exit /b

:banner
cls
:: ESCAPE PIPE CHARACTERS (^|) IN ASCII ART TO PREVENT BATCH SYNTAX ERRORS
echo %FLAME1% __     __   ___    ____     __     __  ___   ____    _____    ___  %RESET%
echo %FLAME1% \ \   / /  / _ \  / ___^|    \ \   / / ^|_ _^| ^|  _ \  ^| ____^|  / _ \ %RESET%
echo %FLAME2%  \ \ / /  ^| ^| ^| ^| \___ \     \ \ / /   ^| ^|  ^| ^| ^| ^| ^|  _^|   ^| ^| ^| ^|%RESET%
echo %FLAME2%   \ V /   ^| ^|_^| ^|  ___) ^|     \ V /    ^| ^|  ^| ^|_^| ^| ^| ^|___  ^| ^|_^| ^|%RESET%
echo %FLAME3%    \_/     \___/  ^|____/       \_/    ^|___^| ^|____/  ^|_____^|  \___/ %RESET%
echo %FLAME3%  ____     ___   __        __  _   _   _        ___      _     ____  %RESET%
echo %FLAME3% ^|  _ \   / _ \  \ \      / / ^| \ ^| ^| ^| ^|      / _ \    / \   ^|  _ \ %RESET%
echo %FLAME3% ^| ^| ^| ^| ^| ^| ^| ^|  \ \ /\ / /  ^|  \^| ^| ^| ^|     ^| ^| ^| ^|  / _ \  ^| ^| ^| ^|%RESET%
echo %FLAME4% ^| ^|_^| ^| ^| ^|_^| ^|   \ V  V /   ^| ^|\  ^| ^| ^|___  ^| ^|_^| ^| / ___ \ ^| ^|_^| ^|%RESET%
echo %FLAME4% ^|____/   \___/     \_/\_/    ^|_^| \_^| ^|_____^|  \___/ /_/   \_\^|____/ %RESET%
echo.
goto :eof
