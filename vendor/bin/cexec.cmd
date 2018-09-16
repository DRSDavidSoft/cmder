@echo off
setlocal

if "%~1" equ "" goto :wrongSyntax

if not defined CMDER_USER_FLAGS (
  :: in case nothing was passed to %CMDER_USER_FLAGS%
  set "CMDER_USER_FLAGS= "
)

set "feNot=false"
goto :parseArgument

:doShift
  shift
  exit /b 0

:parseArgument
set "currenArgu=%~1"
if /i "%currenArgu%" equ "/setPath" (
  :: set %flag_exists% shortcut
  endlocal
  set "ccall=call %~dp0cexec.cmd"
  set "cexec=%~dp0cexec.cmd"
) else if /i "%currenArgu%" == "/?" (
  goto :help
) else if /i "%currenArgu%" equ "/help" (
  goto :help
) else if /i "%currenArgu%" equ "/h" (
  goto :help
) else if /i "%currenArgu%" equ "NOT" (
  set "feNot=true"
  call :doShift
) else (
  if "%~1" equ "" goto :wrongSyntax
  if "%~2" equ "" goto :wrongSyntax
  set "feFlagName=%~1"
  set "feCommand=%~2"
  if not "%~3" equ "" (
    set "feParam=%~3"
  )
  goto :detect
)

:detect
:: to avoid erroneous deteciton like "/do" "/doNOT", which both have a "/do"
:: we added a space after the flag name, like "/do ", which won't match "/doN"
set "feFlagName=%feFlagName% "
:: echo.
:: echo %CMDER_USER_FLAGS%
:: echo %feNOT%
:: echo %feFlagName%
:: echo %feCommand%
:: echo %feParam%
:: echo.
echo %CMDER_USER_FLAGS% | find /i "%feFlagName%">nul
if "%ERRORLEVEL%" == "0" (
  if "%feNOT%" == "false" (
    endlocal && call %feCommand% %feParam%
    exit /b 0
  )
) else (
  if "%feNOT%" == "true" (
    endlocal && call %feCommand% %feParam%
    exit /b 0
  )
)
endlocal
exit /b 1

:wrongSyntax
echo The syntax of the command is incorrect.
echo.
echo use /? for help
echo.
endlocal
exit /b

:help
echo.
echo CExec - Conditional Execution
echo.
echo Handles user custom arguments for Cmder's init.bat
echo   written by xiazeyu, inspired by DRSDavidSoft
echo.
echo Usage:
echo.
echo cexec /setPath [NOT] flagName command/program [parameters]
echo.
echo   /setPath         Generate a global varible %%cexec%% for
echo                    quicker use. Following arguments will be ignored.
echo.
echo   NOT              Specifies that cexec should carry out
echo                    the command only if the flag is missing.
echo.
echo   /[flagName]      Specifies which flag name is to detect. It's recommand
echo                    to use a pair of double quotation marks to wrap
echo                    your flag name to avoid exceed expectation.
echo.
echo   command/program  Specifies the command to carry out if the
echo                    argument name is detected. It's recommand to
echo                    use a pair of double quotation marks to
echo                    wrap your command to avoid exceed expectation.
echo.
echo   parameters       These are the parameters passed to the command/program.
echo                    It's recommand to use a pair of double quotation marks 
echo                    to wrap your flag name to avoid exceed expectation.
echo.
echo Examples:
echo.
echo   These examples are expected to be written in %cmder_root%/config/user-profile.cmd
echo   CExec evaluates the environment varible "CMDER_USER_FLAGS" and conditionally
echo   caries out actions based on flags that are passed.
echo.
echo   Case 1:
echo.
echo   The following command in user-profile.cmd would execute "notepad.exe"
echo.
echo     call cexec "/startNotepad" "start" "notepad.exe"
echo.
echo   If you pass parameter to init.bat like:
echo.
echo     init.bat /startNotepad
echo.
echo   Case 2:
echo.
echo   The following command in user-profile.cmd would execute "notepad.exe"
echo.
echo     call cexec NOT "/dontStartNotepad" "start" "notepad.exe"
echo.
echo   UNLESS you pass parameter to init.bat like:
echo.
echo     init.bat /dontStartNotepad
echo.
endlocal
exit /b