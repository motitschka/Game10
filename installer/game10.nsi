; The Windows installer (FR-WIN-8, ADR 0015). `scripts/release/windows.sh installer` builds it with
; makensis and defines VERSION (Cargo.toml's), VERSION_NUM (its numbers as a.b.c.0), STAGE (a folder
; with the files below and game10.ico) and OUTFILE.
;
; It installs for every user into Program Files, with a Start menu shortcut and an uninstaller in
; Installed apps. Installing over an earlier version replaces it where it is. The uninstaller deletes
; the files listed here and nothing else: never the Config (%APPDATA%\game10), Game10's data
; (%LOCALAPPDATA%\game10) or the Games Root, and never other files someone put in the program folder.

Unicode true
SetCompressor /SOLID lzma
!include MUI2.nsh
!include x64.nsh

!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Game10"
!define PUBLISHER "Matei Novotny"

Name "Game10"
OutFile "${OUTFILE}"
InstallDir "$PROGRAMFILES64\Game10"
RequestExecutionLevel admin
ManifestDPIAware true
BrandingText "Game10 ${VERSION}"

VIProductVersion "${VERSION_NUM}"
VIAddVersionKey "ProductName" "Game10"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "FileDescription" "Game10 ${VERSION} Setup"
VIAddVersionKey "CompanyName" "${PUBLISHER}"
VIAddVersionKey "LegalCopyright" "Copyright (C) 2026 ${PUBLISHER}, GPL-3.0-or-later"

!define MUI_ICON "${STAGE}\game10.ico"
!define MUI_UNICON "${STAGE}\game10.ico"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Function .onInit
    ${IfNot} ${RunningX64}
        MessageBox MB_ICONSTOP "Game10 needs 64-bit Windows." /SD IDOK
        Abort
    ${EndIf}
    SetRegView 64
    ; An earlier version is upgraded where it is.
    ReadRegStr $0 HKLM "${UNINSTALL_KEY}" "InstallLocation"
    ${If} $0 != ""
        StrCpy $INSTDIR $0
    ${EndIf}
FunctionEnd

Section "Game10" SecGame10
    SetShellVarContext all
    SetOutPath "$INSTDIR\fonts"
    File "${STAGE}\fonts\AdwaitaSans-Regular.ttf"
    File "${STAGE}\fonts\AdwaitaSans-LICENSE.txt"
    SetOutPath "$INSTDIR"
    File "${STAGE}\game10.exe"
    File "${STAGE}\SDL3.dll"
    File "${STAGE}\SDL3_ttf.dll"
    File "${STAGE}\LICENSE"
    File "${STAGE}\README.md"
    WriteUninstaller "$INSTDIR\uninstall.exe"
    CreateShortcut "$SMPROGRAMS\Game10.lnk" "$INSTDIR\game10.exe" "" "$INSTDIR\game10.exe" 0

    WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayName" "Game10"
    WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "${UNINSTALL_KEY}" "Publisher" "${PUBLISHER}"
    WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\game10.exe,0"
    WriteRegStr HKLM "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr HKLM "${UNINSTALL_KEY}" "QuietUninstallString" '"$INSTDIR\uninstall.exe" /S'
    SectionGetSize ${SecGame10} $0
    WriteRegDWORD HKLM "${UNINSTALL_KEY}" "EstimatedSize" $0
    WriteRegDWORD HKLM "${UNINSTALL_KEY}" "NoModify" 1
    WriteRegDWORD HKLM "${UNINSTALL_KEY}" "NoRepair" 1
SectionEnd

Function un.onInit
    SetRegView 64
FunctionEnd

Section "Uninstall"
    SetShellVarContext all
    Delete "$SMPROGRAMS\Game10.lnk"
    Delete "$INSTDIR\fonts\AdwaitaSans-Regular.ttf"
    Delete "$INSTDIR\fonts\AdwaitaSans-LICENSE.txt"
    Delete "$INSTDIR\game10.exe"
    Delete "$INSTDIR\SDL3.dll"
    Delete "$INSTDIR\SDL3_ttf.dll"
    Delete "$INSTDIR\LICENSE"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\uninstall.exe"
    ; Only if they are empty now, so that anything else in them stays.
    RMDir "$INSTDIR\fonts"
    RMDir "$INSTDIR"
    DeleteRegKey HKLM "${UNINSTALL_KEY}"
SectionEnd
