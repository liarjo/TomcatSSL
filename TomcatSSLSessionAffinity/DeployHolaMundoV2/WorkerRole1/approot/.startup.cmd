rd "\%ROLENAME%"

if defined DEPLOYROOT_PATH set DEPLOYROOT=%DEPLOYROOT_PATH%
if defined DEPLOYROOT (
	mklink /J "\%ROLENAME%" "%DEPLOYROOT%"
) else (
	mklink /J "\%ROLENAME%" "%ROLEROOT%\approot"
)

set DEPLOYROOT=\%ROLENAME%
set SERVER_APPS_LOCATION=%DEPLOYROOT%

set JAVA_HOME=%DEPLOYROOT%\jdk1.7.0_40
set PATH=%JAVA_HOME%\bin;%PATH%
set CATALINA_HOME=%DEPLOYROOT%\apache-tomcat-7.0.42
set SERVER_APPS_LOCATION=%CATALINA_HOME%\webapps


cmd /c util\wash.cmd blob download "jdk1.7.0_40.zip" "jdk1.7.0_40.zip" jre javarepository "NBX7KQtUuMgvRxUd5i/7izmGJnwJ08c6cBy7bjcKvlBy8zuqzOnpkvvoqlJ46JOCqzfgwgeFnoTIyok24RESWw==" "https://core.windows.net"
if not exist "jdk1.7.0_40.zip" exit 1
cscript /NoLogo util\unzip.vbs "jdk1.7.0_40.zip" "%DEPLOYROOT%"
del /Q /F "jdk1.7.0_40.zip"
cmd /c util\wash.cmd blob download "apache-tomcat-7.0.42.zip" "apache-tomcat-7.0.42.zip" jre javarepository "NBX7KQtUuMgvRxUd5i/7izmGJnwJ08c6cBy7bjcKvlBy8zuqzOnpkvvoqlJ46JOCqzfgwgeFnoTIyok24RESWw==" "https://core.windows.net"
if not exist "apache-tomcat-7.0.42.zip" exit 1
cscript /NoLogo util\unzip.vbs "apache-tomcat-7.0.42.zip" "%DEPLOYROOT%"
del /Q /F "apache-tomcat-7.0.42.zip"
if not "%SERVER_APPS_LOCATION%" == "\%ROLENAME%" if exist "HolaMundov2.war"\* (echo d | xcopy /y /e /q "HolaMundov2.war" "%SERVER_APPS_LOCATION%\HolaMundov2.war" 1>nul) else (echo f | xcopy /y /q "HolaMundov2.war" "%SERVER_APPS_LOCATION%\HolaMundov2.war" 1>nul)
start "Windows Azure" /D"%CATALINA_HOME%\bin" startup.bat


:: *** This script will run whenever Windows Azure starts this role instance.
:: *** This is where you can describe the deployment logic of your server, JRE and applications 
:: *** or specify advanced custom deployment steps
::     (Note though, that if you're using this in Eclipse, you may find it easier to configure the JDK,
::     the server and the server and the applications using the New Windows Azure Deployment Project wizard 
::     or the Server Configuration property page for a selected role.)

echo Hello World!

:: Script Variables

set vcerthash=09D7DF2A1779D027CB52DE223FA30C579182109B
set vUrlTarget=https://tomcatssl.cloudapp.net


:: get ipv4
ipconfig | findstr IPv4 > ipadd.txt
for /F "tokens=14" %%i in (ipadd.txt) do ( 
	@echo %%i 
	set varip=%%i  
)
del ipadd.txt /Q
set varip=%varip: =%

:: Move to directory
cd d:\windows\System32\inetsrv > logArrSetup.txt
d:

:Delete HTTP Binding
appcmd set site /site.name: "Default Web Site"  /-bindings.[protocol='http',bindingInformation='%varip%:31221:'] >> logArrSetup.txt

:Create HTTPS Binding
appcmd set site /site.name: "Default Web Site"  /+bindings.[protocol='https',bindingInformation='%varip%:31221:'] >> logArrSetup.txt

:Add Certificate to HTTPS Binding port
netsh http add sslcert ipport=0.0.0.0:31221 certhash=%vcerthash% appid={4dc3e181-e14b-4a21-b022-59fc669b0914} >> logArrSetup.txt

:Add HTTP Header response to track who instance of ARR is reciving the request
appcmd set config /section:httpProtocol /+customHeaders.[name='X-JPG-ARR',value='%varip%']  >> logArrSetup.txt



:Reset IIS Services to update de configuration Changes
iisreset >> logArrSetup.txt

@ECHO OFF
set ERRLEV=%ERRORLEVEL%
if %ERRLEV%==0 (set _MSG="Startup completed successfully.") else (set _MSG="*** Windows Azure startup failed [%ERRLEV%]- exiting...")
choice /d y /t 5 /c Y /N /M %_MSG%
exit %ERRLEV%