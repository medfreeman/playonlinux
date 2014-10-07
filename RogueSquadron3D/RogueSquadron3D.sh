#!/bin/bash
# Date : (2014-09-18 00:12)
# Last revision : (2014-10-07 14:35)
# Wine version used : 1.7.28
# Distribution used to test : Ubuntu 14.04 Trusty x64 + Debian 7.0 Wheezy x64
# Author : med_freeman
# Licence : Retail
 
[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"
 
TITLE="Rogue Squadron 3D"
PREFIX="RogueSquadron3D"
WINE_VERSION="1.7.28"
WINE_ARCH="x86"
AUTHOR="med_freeman"
 
POL_GetSetupImages "http://files.playonlinux.com/resources/setups/$PREFIX/top.jpg" "http://files.playonlinux.com/resources/setups/$PREFIX/left.jpg" "$TITLE"
POL_SetupWindow_Init
 
POL_Debug_Init
 
POL_SetupWindow_presentation "$TITLE" "LucasArts / Factor 5" "http://www.starwars.com/games-apps" "$AUTHOR" "$PREFIX"
 
POL_System_SetArch "$WINE_ARCH"
POL_System_TmpCreate "$PREFIX"
POL_Wine_SelectPrefix "$PREFIX"
POL_Wine_PrefixCreate "$WINE_VERSION"

# Check game cdrom 
POL_SetupWindow_cdrom
POL_SetupWindow_check_cdrom "rogue"

# Ask user to enable 16 bit support on newer kernels (3.14~) if not enabled
_16BIT="$(cat /proc/sys/abi/ldt16)"
if [ $? -eq 0 ] && [ "$_16BIT" = "0" ]; then
    POL_Call POL_Function_RootCommand "sudo sysctl -w abi.ldt16=1; exit"
fi
 
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$CDROM/setup.exe"
POL_Wine_WaitExit "$TITLE"
 
# Update 1.21 installation
POL_SetupWindow_message "$TITLE : $(eval_gettext 'Installation of update 1.21')" "$TITLE"

POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL"
if [ "$INSTALL_METHOD" = "LOCAL" ]; then
    cd "$HOME"
    POL_SetupWindow_browse "$(eval_gettext 'Please select the 1.21 update executable')" "$TITLE"
    UPDATE_EXE="$APP_ANSWER"
elif [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
    cd "$POL_System_TmpDir"
    UPDATE_EXE="rogueupd12.exe"
    POL_Download "http://media1.gamefront.com/moddb/2009/03/10/$UPDATE_EXE" "e90984f2e3721fe72e67609aabd6db23"
fi
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$UPDATE_EXE"
POL_Wine_WaitExit "$TITLE"

# Dependencies
POL_Call POL_Install_dsound
POL_Wine_OverrideDLL "native" "dsound"

# Install nGlide wrapper
cd "$POL_System_TmpDir"
NGLIDE_EXE="nGlide102_setup.exe"
POL_Download "http://www.zeus-software.com/files/nglide/$NGLIDE_EXE" "3753dd73587af332ad72e7fb73545ab1"
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$NGLIDE_EXE"
POL_Wine_WaitExit "$TITLE"

# Set glide renderer
regfile="$POL_System_TmpDir/rs3d_glide.reg"
cat <<_EOFREG_ >> "$regfile"
[HKEY_LOCAL_MACHINE\\Software\\LucasArts Entertainment Company LLC\\Rogue Squadron\\v1.0]
"3DSetup"="TRUE"
"VDEVICE"="Voodoo (Glide)"
_EOFREG_
regedit $regfile
rm -f $regfile

# Needed Overrides
Set_Managed "Off"
POL_Wine_X11Drv "Decorated" "N"
POL_Wine_X11Drv "GrabFullscreen" "Y"
# Menu glitches
POL_Wine_Direct3D "StrictDrawOrdering" "enabled"
# Joystick
Set_OS "win98"

# Shortcuts
POL_Shortcut "Rogue Squadron.exe" "$TITLE"
POL_Shortcut "nglide_config.exe" "$TITLE - Graphic settings"
 
POL_SetupWindow_message "$(eval_gettext '$TITLE has been successfully installed.')"
 
POL_System_TmpDelete
POL_SetupWindow_Close
exit 0
