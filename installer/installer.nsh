; Custom NSIS installer script for Kalyan Smart Student System
; Windows 7 Compatible

!include "MUI2.nsh"
!include "WinVer.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"

Var LicenseKeyHandle
Var LicenseKeyValue

Function LicensePage
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}

    !insertmacro MUI_HEADER_TEXT "Activation Required" "Please enter your 7-character activation key."

    ${NSD_CreateLabel} 0 0 100% 24u "To continue with the installation of Kalyan Smart Student System, please enter your activation key below:"
    Pop $0

    ${NSD_CreateText} 0 30u 100% 14u ""
    Pop $LicenseKeyHandle
    
    ; Focus the text box
    SendMessage $LicenseKeyHandle ${WM_SETFOCUS} 0 0

    nsDialogs::Show
FunctionEnd

Function LicensePageLeave
    ${NSD_GetText} $LicenseKeyHandle $LicenseKeyValue
    
    ; Validate: The key should be E-K-T-A-S-A-M (case-insensitive, optionally without dashes)
    ; We'll check for the exact string or the version without dashes
    ${If} $LicenseKeyValue == "E-K-T-A-S-A-M"
    ${OrIf} $LicenseKeyValue == "EKTASAM"
    ${OrIf} $LicenseKeyValue == "ektasam"
    ${OrIf} $LicenseKeyValue == "e-k-t-a-s-a-m"
        ; License key is valid
    ${Else}
        MessageBox MB_OK|MB_ICONSTOP "Invalid license key. Please enter the correct 7-character activation key (E-K-T-A-S-A-M) to continue."
        Abort
    ${EndIf}
FunctionEnd

!macro customHeader
  Page custom LicensePage LicensePageLeave
!macroend

!macro preInit
  ; -------------------------------------------------------
  ; Block installation on Windows XP and below (Vista/7+)
  ; -------------------------------------------------------
  ${IfNot} ${AtLeastWin7}
    MessageBox MB_OK|MB_ICONSTOP "This application requires Windows 7 or later. Please upgrade your operating system."
    Abort
  ${EndIf}
!macroend

!macro customInstall
  ; Nothing extra needed post-install
!macroend

