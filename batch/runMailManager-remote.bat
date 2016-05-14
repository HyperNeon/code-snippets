@echo off
for /f "tokens=1,2 delims=:" %%a in ('ipconfig ^| C:\Windows\System32\find.exe "IPv4"') do set IPv4=%%b
set IPv4=%IPv4: =%
set IPv4=%IPv4:.=-%
echo -------
echo Extension will be %IPv4%
echo -------

set OLDDIR=%CD%
echo -------
echo Remapping M:\ to E:\cygwin64\opt\bulkmailer
echo -------
subst /D M:
subst M: E:\cygwin64\opt\bulkmailer
Z:
cd "Z:\"

set TEMP_MJB=%3
set TEMP_MJB=%TEMP_MJB:.mjb=%-%IPv4%.mjb
echo -------
echo Creating %TEMP_MJB%...
echo -------
cmd /c E:\cygwin64\opt\bulkmailer\bin\BatchSubstitute.bat "C:\BCC\MM2010\Lists\/REDACTED/_UseEveryTimeAndOverwrite_1.dbf" /REDACTED/\MM2010\Lists\/REDACTED/_UseEveryTimeAndOverwrite_%IPv4%.dbf Z:\Jobs\%3 > Z:\Jobs\%TEMP_MJB%
echo -------
echo Finished creating %TEMP_MJB% file in Z:\Jobs...
echo -------
set MailManEnvironment=%1
if "%MailManEnvironment%"=="production" set MailManEnvironment="\"
set MailManParams=%2 %TEMP_MJB% %4 %5
echo -------
echo Here are the following MailaManParams = %MailManParams%
C:\BCC\MM2010\MailMan-Admin-Remote.lnk

:do_wait_for_completion
sleep 5
tasklist /FI "IMAGENAME eq MailMan.exe" 2>NUL  | C:\Windows\System32\find.exe /I /N "MailMan.exe">NUL
if  "%errorlevel%"=="0" goto do_wait_for_completion

DEL Z:\Jobs\%TEMP_MJB%
echo Deleting Z:\Jobs\%TEMP_MJB%

cd /d %OLDDIR%

