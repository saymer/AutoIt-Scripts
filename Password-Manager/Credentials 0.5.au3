; Created by Salvador Madrid
; Created 3-13-2017

#include <String.au3>
#include <Crypt.au3>
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>


Opt("GUIOnEventMode", 1)

;Global variables declaration
Global $List, $Status = 0, $MainGui, $EditGui, $EditCredentials
Global $DecryptKey, $UsernameInput, $PasswordInput, $InfoInput, $KeyInput, $FirstEntry = 0, $Permission = 0


; Starts program
_Login()
_CreateMainGui()


;########################### FUNCTIONS #################################

;Login function to access data
Func _Login()
   $CheckForKey = IniRead(@AppDataDir & "/Cred_Data/Credentials.ini", "Key", "Key", "NA")
   If $CheckForKey = "NA" Then
	  $GetNewKey = InputBox("Encryption Key", "You appear to not have created an encryption key to use with this software. Please do so before using the software!")
	  If $GetNewKey = "" Then
		 MsgBox(48, "Error", "No key input, please run the program again. You must use an encryption key for this program to work!")
		 Exit
	  EndIf
	  $CheckInformation = MsgBox(4, "Encryption Key", "Do you wish to use this as your encryption key: " & $GetNewKey)
	  If $CheckInformation = 6 Then
		 $EncryptNewKey = _Crypt_EncryptData($GetNewKey, $GetNewKey, $CALG_RC4)
		 ; create directory if it does not exist
		 $DataDir = @AppDataDir & "/Cred_Data"
		 If DirGetSize($DataDir)  -1 Then
			DirCreate($DataDir)
		 EndIf
		 IniWrite(@AppDataDir & "/Cred_Data/Credentials.ini", "Key", "Key", $EncryptNewKey)
		 MsgBox(0, "Encryption Key", "Encryption key has been saved!" )
	  Else
		 MsgBox(48, "Encryption Key", "Encryption key creation has been cancelled! Please run the program again if you wish to!")
		 Exit
	  EndIf
   EndIf
EndFunc


;Create interface user
Func _CreateMainGui()
    $MainGui = GUICreate("Credential Creator", 400, 480)
    GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")

    GUICtrlCreateLabel("Password Manager", 100, 50, 200, 40)
    GUICtrlSetFont(-1, 16)

    GUICtrlCreateLabel("Username", 40, 110, 200, 40)
    GUICtrlSetFont(-1, 10)

    $UsernameInput = GUICtrlCreateInput("", 40, 130, 300, 30)
    GUICtrlSetColor(-1, 0xe50000)
    GUICtrlSetFont(-1, 10)

    GUICtrlCreateLabel("Password", 40, 170, 200, 40)
    GUICtrlSetFont(-1, 10)

    $PasswordInput = GUICtrlCreateInput("", 40, 190, 300, 30)
    GUICtrlSetColor(-1, 0xe50000)
    GUICtrlSetFont(-1, 10)

	GUICtrlCreateLabel("Information", 40, 230, 200, 40)
    GUICtrlSetFont(-1, 10)

    $InfoInput = GUICtrlCreateInput("", 40, 250, 300, 30)
    GUICtrlSetColor(-1, 0xe50000)
    GUICtrlSetFont(-1, 10)

    GUICtrlCreateLabel("Encryption Key", 40, 310, 200, 40)
    GUICtrlSetFont(-1, 10)

    $KeyInput = GUICtrlCreateInput("", 40, 330, 300, 30,$ES_PASSWORD)
    GUICtrlSetColor(-1, 0xe50000)
    GUICtrlSetFont(-1, 10)

    $AddCredential = GUICtrlCreateButton("Add Credentials", 40, 390, 115, 70)
    GUICtrlSetOnEvent(-1, "_AddCredentials")
    GUICtrlSetFont(-1, 10)

    $EditCredentials = GUICtrlCreateButton("Edit/Remove" & @CRLF & "Credentials", 205, 390, 135, 70,$BS_MULTILINE)
    GUICtrlSetOnEvent(-1, "_CreateEditGui")
    GUICtrlSetFont(-1, 10)
    GUISetState()
EndFunc   ;==>_CreateMainGui

;Interaction with 'AddCredentials' button
Func _AddCredentials()
    $ReadUsername = GUICtrlRead($UsernameInput)
    $ReadPassword = GUICtrlRead($PasswordInput)
	$ReadInfo = GUICtrlRead($InfoInput)
    $ReadEncryptionKey = GUICtrlRead($KeyInput)
    $ReadKey = IniRead(@AppDataDir & "/Cred_Data/Credentials.ini", "Key", "Key", "NA")
    $DecryptKey = _Crypt_DecryptData($ReadKey, $ReadEncryptionKey, $CALG_RC4)
    $TranslateKey = BinaryToString($DecryptKey)
    If $ReadEncryptionKey = $TranslateKey Then
        $CheckInformation = MsgBox(4, "Add Credentials", "Are you sure you wish to add the credentials for: " & $ReadUsername)
        If $CheckInformation = 6 Then
            $ReadIni = IniReadSection(@AppDataDir & "/Cred_Data/Credentials.ini", "Credentials")
			; Check for section initialized, if not assume it is now and set counter to 1
			If @error Then
				$NextKey = 1
			Else
				$NextKey = $ReadIni[0][0] + 1
			EndIf
            ; Gives current count add 1 to add to INI
            $EncryptNewUsername = _Crypt_EncryptData($ReadUsername, $ReadEncryptionKey, $CALG_RC4)
            $EncryptNewPassword = _Crypt_EncryptData($ReadPassword, $ReadEncryptionKey, $CALG_RC4)
			$EncryptNewInfo = _Crypt_EncryptData($ReadInfo, $ReadEncryptionKey, $CALG_RC4)
            IniWrite(@AppDataDir & "/Cred_Data/Credentials.ini", "Credentials", $NextKey , $EncryptNewUsername & "|" & $EncryptNewPassword & "|" & $EncryptNewInfo)
            GUICtrlSetData($UsernameInput, "")
            GUICtrlSetData($PasswordInput, "")
			GUICtrlSetData($InfoInput, "")
            MsgBox(0, "Add Credentials", "Addition of credential " & $ReadUsername & " is complete!")
			;Exit
        Else
            MsgBox(0, "Add Credentials", "Cancelling the addition of the credentials!")
        EndIf
    Else
        MsgBox(48, "Error", "Encryption key is invalid. Please try again!")
    EndIf
EndFunc   ;==>_AddCredentials

;Create interface user into sub-menu edit
Func _CreateEditGui()
    GUISetState(@SW_DISABLE, $MainGui)
	;Check User Permission
    If $FirstEntry = 0 Then
        $GetEncryptionKey = InputBox("Security Check", "Please input the correct encryption key!","","*")
        $ReadKey = IniRead(@AppDataDir & "/Cred_Data/Credentials.ini", "Key", "Key", "NA")
        $DecryptKey = _Crypt_DecryptData($ReadKey, $GetEncryptionKey, $CALG_RC4)
        If $DecryptKey = $GetEncryptionKey Then
            MsgBox(0, "Security Check", "Decryption successful, welcome, " & @UserName)
        Else
            MsgBox(48, "Error", "Encryption key is invalid please try again!")
            $Permission = 1
        EndIf
        $FirstEntry = 1
    EndIf
    If $Permission = 0 Then
        $EditGui = GUICreate("Credential Editor", 400, 480)
        GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseGui")
        $List = GUICtrlCreateListView("Username|Password|Information", 10, 10, 380, 380)
        _GUICtrlListView_SetColumnWidth($List, 0, 110)
        _GUICtrlListView_SetColumnWidth($List, 1, 110)
		_GUICtrlListView_SetColumnWidth($List, 2, 150)

        $EditButton = GUICtrlCreateButton("Edit", 40, 410, 70, 40)
        GUICtrlSetOnEvent(-1, "_Edit")
        GUICtrlSetFont(-1, 10)

		$DeleteButton = GUICtrlCreateButton("Delete ", 170, 410, 70, 40)
        GUICtrlSetOnEvent(-1, "_Delete")
        GUICtrlSetFont(-1, 10)

        $CloseButton = GUICtrlCreateButton("Close", 300, 410, 70, 40)
        GUICtrlSetOnEvent(-1, "_CloseGUi")
        GUICtrlSetFont(-1, 10)

        $ReadCredentialCount = IniReadSection(@AppDataDir & "/Cred_Data/Credentials.ini", "Credentials")
        If @error Then
            GUICtrlSetState($EditButton, $GUI_DISABLE)
            GUICtrlSetState($DeleteButton, $GUI_DISABLE)
        Else
            For $i = 1 To $ReadCredentialCount[0][0]
                $SplitData = StringSplit($ReadCredentialCount[$i][1], "|")
                $DecryptUserName = _Crypt_DecryptData($SplitData[1], $DecryptKey, $CALG_RC4)
                $DecryptPassword = _Crypt_DecryptData($SplitData[2], $DecryptKey, $CALG_RC4)
				$DecryptInfo = _Crypt_DecryptData($SplitData[3], $DecryptKey, $CALG_RC4)
                $DecryptedUserName = BinaryToString($DecryptUserName)
                $DecryptedPassword = BinaryToString($DecryptPassword)
				$DecryptedInfo = BinaryToString($DecryptInfo)
                $ListViewData = $DecryptedUserName & "|" & $DecryptedPassword & "|" & $DecryptedInfo
                GUICtrlCreateListViewItem($ListViewData, $List)
            Next
        EndIf

        GUISetState()
    Else
        GUISetState(@SW_ENABLE, $MainGui)
        Sleep(100)
        WinActivate($MainGui)
        $Permission = 0
        $FirstEntry = 0
    EndIf
EndFunc   ;==>_CreateEditGui

;Interaction with 'Edit' button
;Edit entry in file .ini
Func _Edit()
    $Status = 0
    $GetSelected = ControlListView($EditGui, "", $List, "GetSelected")
    $GetUserName = ControlListView($EditGui, "", $List, "GetText", $GetSelected)
    $GetPassword = ControlListView($EditGui, "", $List, "GetText", $GetSelected, 1)
	$GetInfo = ControlListView($EditGui, "", $List, "GetText", $GetSelected, 2)
	;While status = 0 search in BD
    While $Status = 0
        $NewUsername = InputBox("Edit Credentials", "Please input the new username", $GetUserName)
        $NewPassword = InputBox("Edit Credentials", "Please input the new password", $GetPassword)
		$NewInfo = InputBox("Edit Credentials", "Please input the new information", $GetInfo)
        If $NewUsername = "" Or $NewPassword = "" Or $NewInfo = "" Then
            MsgBox(48, "Error", "Username or password was not input. If you wish to remove the credentials remember to type 'Blank' in the boxes without the quoataions.")
            $Status = 0
			;***********************************
        EndIf
        If $NewUsername > "" And $NewPassword > "" And $NewInfo > "" Then
            $CheckInformation = MsgBox(4, "Edit Credentials", "Is this the information you wish to save?" & @CRLF & @CRLF & "Username: " & $NewUsername & @CRLF & _
                    "Password: " & $NewPassword & @CRLF & "Information: " & $NewInfo)
            If $CheckInformation = 6 Then
			   ;Edit exist entry
			   $EncryptNewUsername = _Crypt_EncryptData($NewUsername, $DecryptKey, $CALG_RC4)
			   $EncryptNewPassword = _Crypt_EncryptData($NewPassword, $DecryptKey, $CALG_RC4)
			   $EncryptNewInfo = _Crypt_EncryptData($NewInfo, $DecryptKey, $CALG_RC4)
			   $ReadIni = IniReadSection(@AppDataDir & "/Cred_Data/Credentials.ini", "Credentials")
			   ;For each credential compare if it is the same and swap
			   For $i = 1 To $ReadIni[0][0]
				  $SplitData = StringSplit($ReadIni[$i][1], "|")
				  $DecryptUserName = _Crypt_DecryptData($SplitData[1], $DecryptKey, $CALG_RC4)
				  $DecryptPassword = _Crypt_DecryptData($SplitData[2], $DecryptKey, $CALG_RC4)
				  $DecryptInfo = _Crypt_DecryptData($SplitData[3], $DecryptKey, $CALG_RC4)
				  $DecryptedUserName = BinaryToString($DecryptUserName)
				  $DecryptedPassword = BinaryToString($DecryptPassword)
				  $DecryptedInfo = BinaryToString($DecryptInfo)

				  If $DecryptedUserName = $GetUserName And $DecryptedPassword = $GetPassword And $DecryptedInfo = $GetInfo Then
					 IniWrite(@AppDataDir & "/Cred_Data/Credentials.ini", "Credentials", $i, $EncryptNewUsername & "|" & $EncryptNewPassword & "|" & $EncryptNewInfo)
					 ExitLoop
				  EndIf
			   Next
			   MsgBox(0, "Edit Credentials", "Credentials have been changed!")
			   GUIDelete($EditGui)
			   _CreateEditGui()
			   $Status = 1
            Else
                $Status = 0
            EndIf
        EndIf
    WEnd
EndFunc   ;==>_Edit

;Close GUI function
Func _CloseGui()
    $FirstEntry = 0
    GUIDelete($EditGui)
    GUISetState(@SW_ENABLE, $MainGui)
    Sleep(100)
    WinActivate($MainGui)
EndFunc   ;==>_CloseGui

;Delate entry in file .ini
Func _Delete()

   $Status = 0
   $GetSelected = ControlListView($EditGui, "", $List, "GetSelected")
   $GetUserName = ControlListView($EditGui, "", $List, "GetText", $GetSelected)
   $GetPassword = ControlListView($EditGui, "", $List, "GetText", $GetSelected, 1)
   $GetInfo = ControlListView($EditGui, "", $List, "GetText", $GetSelected, 2)
   $ReadIni = IniReadSection(@AppDataDir & "/Cred_Data/Credentials.ini", "Credentials")

   For $i = 1 To $ReadIni[0][0]
	  $SplitData = StringSplit($ReadIni[$i][1], "|")
	  $DecryptUserName = _Crypt_DecryptData($SplitData[1], $DecryptKey, $CALG_RC4)
	  $DecryptPassword = _Crypt_DecryptData($SplitData[2], $DecryptKey, $CALG_RC4)
	  $DecryptInfo = _Crypt_DecryptData($SplitData[3], $DecryptKey, $CALG_RC4)
	  $DecryptedUserName = BinaryToString($DecryptUserName)
	  $DecryptedPassword = BinaryToString($DecryptPassword)
	  $DecryptedInfo = BinaryToString($DecryptInfo)
	  If $DecryptedUserName = $GetUserName And $DecryptedInfo = $GetInfo And $DecryptedPassword = $GetPassword Then
		 IniDelete(@AppDataDir & "/Cred_Data/Credentials.ini", "Credentials", $i)
	  EndIf
   Next
   MsgBox(0, "Edit Credentials", "Credentials have been changed!")
   GUIDelete($EditGui)
   _CreateEditGui()
   $Status = 1
EndFunc

Func _Exit()
    Exit
EndFunc   ;==>_Exit


While 1
    Sleep(10)
WEnd
