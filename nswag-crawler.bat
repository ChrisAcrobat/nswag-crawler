@ECHO OFF
setlocal EnableDelayedExpansion

set defaultSleep=60

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
		for /f "delims=" %%A in ('CALL nswag run "%%~nF%%~xF"') do (
			set row=%%A
			set check=!row:Exception=!
			if not !row!==!check! (
				set exception=true
			)
		)
		if !exception! == true (
			ECHO Could not be called: !file!
		)
		CD /D "%root%"
	)
)
timeout /t !sleep! /nobreak > NUL
ECHO !date! !time:~0,-3!
goto loop
