::Ver 0.1.0
@echo off

setlocal enabledelayedexpansion

SET NEWLINE=^& echo.

for /F "tokens=*" %%A in ('curl -s https://raw.githubusercontent.com/febkosq8/WindowsHostManager/main/hostData') do (
  FIND /C /I "%%A" %WINDIR%\system32\drivers\etc\hosts
  IF !ERRORLEVEL! NEQ 0 (
    ECHO.%%A>>%WINDIR%\System32\drivers\etc\hosts
    ECHO %%A WAS ADDED TO HOSTS SUCCESSFULLY
  ) ELSE (
    ECHO %%A WAS ALREADY IN HOSTS
    )
)

pause