@ECHO OFF
setlocal EnableDelayedExpansion

set defaultSleep=60

set tempLog=error.%RANDOM%.temp.log
set root=%~dp0
set excludeFile=%~n0%~x0.exclude
set sleep=%1
if "!sleep!" == "" (
	set sleep=!defaultSleep!
)
>nul findstr /c:"%~n0%~x0 " !excludeFile!
if !errorlevel! == 1 (
	echo %~n0%~x0 >> !excludeFile!
)
>nul findstr /c:"%~n0%~x0.exclude " !excludeFile!
if !errorlevel! == 1 (
	echo %~n0%~x0.exclude >> !excludeFile!
)
:loop
FOR /R "%root%" %%F in (*nswag*) do (
	set file=%%F
	set file=!file:%root%=!
	>nul findstr /c:"!file!" !excludeFile!
	if !errorlevel! == 1 (
		CD /D "%%~pF"
		CALL nswag run "%%~nF%%~xF" > !tempLog!
		set exception=false
		for /f %%i in ('FINDSTR Exception !tempLog!') do (
			set exception=true
		)
		del !tempLog!
		if !exception! == true (
			ECHO Could not be called: !file!
		)
		CD /D "%root%"
	)
)
timeout /t !sleep! /nobreak > NUL
ECHO !date! !time:~0,-3!
goto loop
