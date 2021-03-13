@ECHO Off
::Returns a IP, NETBIOS and DNS name from a IP, NETBIOS or DNS name being passed in.
::Syntax: RESOLVE 192.168.1.1
::Syntax: RESOLVE SERVERNAME
::Syntax: RESOLVE SRVR.DOMAIN.COM
::Jack Kress - 2/26/04
:: v3

SETLOCAL
SET SCRIPTNAME=%~n0
IF "%1"=="" ECHO Incorrect Syntax - use: %SCRIPTNAME% NETBIOSNAME && GOTO :EOF
FOR /F "tokens=3delims=: " %%I IN ('PING -n 1 %1 ^| FIND "Reply from"') DO (
 SET IP=%%I
 FOR /F "tokens=2 delims=:" %%J IN ('NSLOOKUP %%I ^| FIND "Name:"') DO SET DNS=%%J
 FOR /F %%K IN ('NBTSTAT -A %%I ^| FIND "<00>  UNIQUE"') DO SET NETBIO=%%K
)
IF NOT DEFINED IP @ECHO %1 is invalid or NETWORK error occurred. && GOTO :EOF
@ECHO.
@ECHO IP ADDRESS =   %IP%
IF NOT DEFINED DNS @ECHO %1 - invalid DNS name or DNS error occurred. && GOTO :EOF
@ECHO DNS NAME = %DNS%
IF NOT DEFINED NETBIO @ECHO %1 - invalid NETBIOS name or WINS error occurred. && GOTO :EOF
@ECHO NETBIOS NAME = %NETBIO%
ENDLOCAL

