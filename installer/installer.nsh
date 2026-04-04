; Custom NSIS installer script for activation key validation
; This script adds an activation key page to the installer

!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"

Var ActivationKeyDialog
Var ActivationKeyLabel
Var ActivationKeyInput
Var ActivationKeyValue

; The correct activation key (hashed comparison below)
!define VALID_KEY "27d6203d-1c4e-4b9e-8373-83bb32a21d43"

!macro customHeader
  ; Nothing extra needed here
!macroend

!macro preInit
  ; Nothing extra needed here
!macroend

; Custom page for activation key
Function ActivationKeyPageCreate
  nsDialogs::Create 1018
  Pop $ActivationKeyDialog

  ${If} $ActivationKeyDialog == error
    Abort
  ${EndIf}

  ; Set a nice title
  !insertmacro MUI_HEADER_TEXT "Product Activation" "Please enter your activation key to continue installation."

  ; Description label
  ${NSD_CreateLabel} 0 0 100% 40u "This software requires a valid activation key to install.$\r$\n$\r$\nPlease enter the activation key provided by Kalyan College administration:"
  Pop $ActivationKeyLabel

  ; Activation key input field
  ${NSD_CreateText} 0 50u 100% 14u ""
  Pop $ActivationKeyInput

  ; Placeholder hint
  ${NSD_CreateLabel} 0 70u 100% 12u "Format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  Pop $0

  nsDialogs::Show
FunctionEnd

; Validate the activation key when leaving the page
Function ActivationKeyPageLeave
  ${NSD_GetText} $ActivationKeyInput $ActivationKeyValue

  ; Check if empty
  ${If} $ActivationKeyValue == ""
    MessageBox MB_ICONEXCLAMATION|MB_OK "Activation key is required. Please enter a valid key."
    Abort
  ${EndIf}

  ; Validate against the correct key
  ${If} $ActivationKeyValue != "${VALID_KEY}"
    MessageBox MB_ICONEXCLAMATION|MB_OK "Invalid activation key.$\r$\n$\r$\nPlease contact Kalyan College administration for a valid key."
    Abort
  ${EndIf}

  ; If we reach here, the key is valid
  MessageBox MB_ICONINFORMATION|MB_OK "Activation successful! Installation will now proceed."
FunctionEnd

!macro customInstall
  ; Nothing extra needed post-install
!macroend

; Insert the custom page into the installer sequence
!macro customPageAfterChangeDir
  Page custom ActivationKeyPageCreate ActivationKeyPageLeave
!macroend
