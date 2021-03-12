# Flinduino Board Driver NSIS Install Script
# Author: Craig Dawson

# Import some useful functions.
!include WinVer.nsh   # Windows version detection.
!include x64.nsh      # X86/X64 version detection.

# Set attributes that describe the installer.
#Icon "Assets\adafruit.ico"
Caption "Flinders Flinduino Board Drivers"
Name "Flinduino board drivers"
Outfile "Flinduino Driver installer.exe"
ManifestSupportedOS "all"
SpaceTexts "none"

# Install driver files to a temporary location (then dpinst will handle the real install).
InstallDir "$TEMP\flinduino_inst"

RequestExecutionLevel admin

# Set properties on the installer exe that will be generated.
VIAddVersionKey /LANG=1033 "ProductName" "Flinders Flinduino Driver"
VIAddVersionKey /LANG=1033 "CompanyName" "Flinders University"
VIAddVersionKey /LANG=1033 "LegalCopyright" "Flinders University"
VIAddVersionKey /LANG=1033 "FileDescription" "Installer for Flinders Flinduino board driver."
VIAddVersionKey /LANG=1033 "FileVersion" "1.0.0"
VIProductVersion "1.0.0.0"
VIFileVersion "1.0.0.0"

# Define variables used in sections.
Var dpinst   # Will hold the path and name of dpinst being used (x86 or x64).

# Components page allows user to pick the drivers to install.
PageEx components
  ComponentText "Check the board drivers below that you would like to install.  Click install to start the installation." \
    "" "Select board drivers to install:"
PageExEnd

# Instfiles page does the actual installation.
Page instfiles


# Sections define the components (drivers) that can be installed.
# The section name is displayed in the component select screen and if selected
# the code in the section will be executed during the install.
# Note that /o before the name makes the section optional and not selected by default.

# This first section is hidden and always selected so it runs first and bootstraps
# the install by copying all the files and dpinst to the temp folder location.
Section
  # Copy all the drivers and dpinst exes to the temp location.
  SetOutPath $INSTDIR
  File /r "Driver"
  File "Certmgr.exe"
  File "DPinst_x64.exe"
  File "DPinst_X86.exe"
  
  # Set dpinst variable based on the current OS type (x86/x64).
  ${If} ${RunningX64}
    StrCpy $dpinst "$INSTDIR\DPinst_x64.exe"
  ${Else}
    StrCpy $dpinst "$INSTDIR\DPinst_x86.exe"
  ${EndIf}
  
SectionEnd

Section "Flinduino Driver"
  #use certmgr to install the certificate
  ExecWait 'Certmgr.exe -add "$INSTDIR\Driver\FlindersFlinduino.cer" -s -r localMachine TrustedPublisher'
  ExecWait 'Certmgr.exe -add "$INSTDIR\Driver\FlindersFlinduino.cer" -s -r localMachine ROOT'
  
  
  # Use pnputil to install the driver.
  #ExecWait 'c:\Windows\System32\pnputil /add-driver "$INSTDIR\Driver\Flinders Flinduino.inf" /install'
  
  # Note the following options are specified:
  #  /sw = silent mode, hide the installer but not OS prompts (critical!)
  #  /path = path to directory with driver data
  ExecWait '"$dpinst" /sw /path "$INSTDIR\Driver"'
SectionEnd