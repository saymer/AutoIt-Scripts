#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Salvador Madrid (saymer)

 Script Function: Open and 'Save As' excel file

#ce ----------------------------------------------------------------------------

#include <Excel.au3>

; Create application object and open an example workbook
Local $oExcel = _Excel_Open()
If @error Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSaveAs Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Local $oWorkbook = _Excel_BookOpen($oExcel, @ScriptDir & "\PUT NAME OF FILE HERE.xls")
If @error Then
    MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSaveAs Example", "Error opening workbook '" & @ScriptDir & "index.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
    _Excel_Close($oExcel)
    Exit
EndIf
; *****************************************************************************
; Save the workbook (xls) in another format (html) to another directory and
; overwrite an existing version
; *****************************************************************************
Local $sWorkbook = @ScriptDir & "\PUT NAME OF FILE HERE.html"
_Excel_BookSaveAs($oWorkbook, $sWorkbook, $xlHtml, True)
If @error Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSaveAs Index.html", "Error saving workbook to '" & $sWorkbook & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSaveAs index.html", "Workbook successfully saved as '" & $sWorkbook & "'.")
;ShellExecute($sWorkbook)
Local $cExcel = _Excel_Close($oExcel)

;End file