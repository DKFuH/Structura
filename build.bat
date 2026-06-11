@echo off
setlocal

:: -------------------------------------------------------
:: build.bat  —  Structura lokaler Release-Build
:: Aufruf:  build.bat [version]
:: Beispiel: build.bat 0.1.0
:: -------------------------------------------------------

set VERSION=%1
if "%VERSION%"=="" set VERSION=dev

echo.
echo =================================================
echo  Structura Build  v%VERSION%
echo =================================================
echo.

:: Lazarus lazbuild.exe suchen
set LAZBUILD=
for %%P in (
    "C:\lazarus\lazbuild.exe"
    "C:\Program Files\Lazarus\lazbuild.exe"
    "C:\Program Files (x86)\Lazarus\lazbuild.exe"
) do (
    if exist %%P set LAZBUILD=%%P
)

if "%LAZBUILD%"=="" (
    echo FEHLER: lazbuild.exe nicht gefunden.
    echo Bitte Lazarus-Pfad in build.bat anpassen.
    pause
    exit /b 1
)

echo Kompiliere mit: %LAZBUILD%
%LAZBUILD% --build-mode=default --no-write-project structura.lpi
if errorlevel 1 (
    echo.
    echo FEHLER: Kompilierung fehlgeschlagen.
    pause
    exit /b 1
)

echo.
echo Erstelle Release-Paket...

set OUTDIR=release
if exist "%OUTDIR%" rd /s /q "%OUTDIR%"
mkdir "%OUTDIR%"

copy /Y Structura.exe "%OUTDIR%\Structura.exe"
copy /Y README.md     "%OUTDIR%\README.md"
copy /Y LICENSE       "%OUTDIR%\LICENSE"

set ZIPNAME=Structura-v%VERSION%-windows-x64.zip

:: PowerShell fuer ZIP nutzen (ab Windows 10 eingebaut)
powershell -Command "Compress-Archive -Path '%OUTDIR%\*' -DestinationPath '%ZIPNAME%' -Force"
if errorlevel 1 (
    echo FEHLER: ZIP konnte nicht erstellt werden.
    pause
    exit /b 1
)

echo.
echo =================================================
echo  Fertig: %ZIPNAME%
echo =================================================
echo.
echo Naechste Schritte:
echo   1. ZIP auf GitHub Release hochladen:
echo      https://github.com/dklas85/structura/releases/new
echo   2. Oder automatisch via Tag:
echo      git tag v%VERSION%
echo      git push origin v%VERSION%
echo.
pause
