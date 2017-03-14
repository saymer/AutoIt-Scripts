#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Salvador Madrid (saymer)

 Script Function: Send item in FTP and generate log file.
 IMPORTANT: Change the fields with '!!!!' to configure your ftp connection

#ce ----------------------------------------------------------------------------

#include <FTP.au3>
#include <WinINet.au3>
#include <WinINetConstants.au3>
#include <MsgBoxConstants.au3>



_CreateWebModel()

$server = '!!!!Put your server here'
$username = '!!!!Put your UserName here'
$pass = '!!!!Put your password here'

;create connection
$Open = _FTPOpen('FTP Control')
$Conn = _FTPConnect($Open, $server, $username, $pass)
;delate file in remote
$Ftpdf = _FTPDelFile($Conn, 'Put your file here')
;push file sorce to destiny
$Ftpp = _FtpPutFile($Conn, 'Put your file here (local)', 'Put your file here(remote)')
;Close stream
$Ftpc = _FTPClose($Open)
;Put Log file access into remote FTP
_Log()
MsgBox(0,"FTP","Finish. Item sended OK.")




;*********** FUNCTIONS *****************



;####### FTP LOG #######

Func _Log()

   ;************VARIABLES****
   Opt("GUIOnEventMode", 1)

   Dim $user = 'user'
   Dim $pwd = 'password'
   Dim $server = 'server'
   Dim $port = 21
   Dim $searchfile = '/Log.txt' ;Necesary absolute path

   ;*************************
   ;Initialize connection
   _WinINet_Startup()
   $InternetOpen = _WinINet_InternetOpen()
   $InternetConnect = _WinINet_InternetConnect($InternetOpen, $INTERNET_SERVICE_FTP, $server, $port, 0, $user, $pwd)
   ;Find log file
   $searchresult = _WinINet_FtpFindFirstFile($InternetConnect,$searchfile)
   If Not @error Then
	  ;Download old log file
	  _WinINet_FtpGetFile($InternetConnect, $searchfile, 'Log.txt')
   EndIf
   ;Open and edit with new data
   $f = FileOpen('LastModificationLog.txt', 9)
   FileWriteLine($f,"Last Modification -> " & @MDAY & "/" & @MON & "/" & @YEAR & " at " & @HOUR & ':' & @MIN & ':' & @SEC)
   FileClose($f)
   ;Send Log file to FTP
   _WinINet_FtpPutFile($InternetConnect, 'Log.txt', $searchfile)
   ;Close streaming
   _WinINet_InternetCloseHandle($InternetConnect)
   _WinINet_InternetCloseHandle($InternetOpen)
   _WinINet_Shutdown()

EndFunc

;#########################



