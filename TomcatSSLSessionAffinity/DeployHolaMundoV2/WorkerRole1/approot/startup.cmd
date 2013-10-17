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