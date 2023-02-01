::Ver 0.2.0
@echo off

set progTitle=Windows Host Manager
set remoteLink=https://raw.githubusercontent.com/febkosq8/WindowsHostManager/main/hostData

setlocal enabledelayedexpansion

SET NEWLINE=^& echo.
title %progTitle%
 

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo %progTitle% is not running with administrative privileges !
    echo Press any key to elavate %progTitle%
    pause >nul 2>&1
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto HostUpdater )

:-------------------------------------
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:-------------------------------------
:HostUpdater
    echo:
    echo STARTING HOST UPDATE
    echo:
    set /A totalCount=0
    set /A updateCount=0
    set /A failedCount=0
    set /A dupCount=0
    for /F "tokens=*" %%A in ('curl -s !remoteLink! --ssl-no-revoke') do (
      set /A totalCount = !totalCount!+1
      FIND /C /I "%%A" %WINDIR%\system32\drivers\etc\hosts >nul 2>&1
      IF !ERRORLEVEL! NEQ 0 (
        ECHO.%%A>>%WINDIR%\System32\drivers\etc\hosts
        FIND /C /I "%%A" %WINDIR%\system32\drivers\etc\hosts >nul 2>&1
        IF !ERRORLEVEL! EQU 0 (    
          set /A updateCount = !updateCount!+1
          ECHO ENTRY:%%A WAS ADDED TO HOSTS SUCCESSFULLY
        ) ELSE (
          ECHO FAILED TO ADD ENTRY:%%A HOSTS !
          set /A failedCount = !failedCount!+1
        )
      ) ELSE (
        ECHO ENTRY:%%A WAS ALREADY FOUND IN HOSTS
        set /A dupCount=!dupCount!+1
        )
    )
    echo -------------------------------------
    echo:
    echo POST ACTION REPORT
    echo:
    echo Number of entries pulled from server : %totalCount%
    echo Number of entries added : %updateCount%
    echo Number of entries skipped : %dupCount%
    echo Number of entries failed : %failedCount%
    echo:
    echo PRESS ANY KEY TO EXIT

    pause >nul 2>&1
:-------------------------------------