; Custom NSIS installer script for Kalyan Smart Student System
; Windows 7 Compatible

!include "MUI2.nsh"
!include "WinVer.nsh"

!macro customHeader
  ; Nothing extra needed here
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
