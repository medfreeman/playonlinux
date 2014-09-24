#!/bin/bash
# Date : (2014-09-18 00:12)
# Last revision : (2014-09-24 02:10)
# Wine version used : 1.7.26
# Distribution used to test : Ubuntu 14.04 Trusty x64
# Author : med_freeman
# Licence : Retail

[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"

TITLE="Rogue Squadron 3D"
PREFIX="RogueSquadron3D"
WINE_VERSION="1.7.26"
WINE_ARCH="x86"
SERVER="http://ftp.oktopod.tv/POL"

POL_Wine_CustomExportRegistryKey()
{
	# Export a registry key to a registry file in tmp folder
	# Needs : POL_System_TmpCreate
	# Usage : POL_Wine_CustomGetRegValue RegKey File
	# Returns : nothing
	# Example : POL_Wine_CustomGetRegValue "HKEY_LOCAL_MACHINE\Software\Monolith Productions\No One Lives Forever 2\1.0" "nolf2.reg"
		
	[ -z "$POL_System_TmpDir" ] && POL_Debug_Fatal "TEMP DIR not set"
	regedit /E "$POL_System_TmpDir/$2" "$1"
}

POL_Wine_CustomGetRegValue()
{
	# Get a value in a registry file in tmp folder
	# Needs : POL_System_TmpCreate
	# Usage : POL_Wine_CustomGetRegValue RegValue File
	# Returns : registry value
	# Example : POL_Wine_CustomGetRegValue "NetRegionCode" "nolf2.reg"
	
	[ -z "$POL_System_TmpDir" ] && POL_Debug_Fatal "TEMP DIR not set"
	local value
	[ -e "$POL_System_TmpDir/$2" ] && value="$(grep "$1" "$POL_System_TmpDir/$2" | head -n 1 | tr -d '"' | cut -d= -f2 | tr -d '\015')"
	POL_Debug_Message "Getting registry value $1 on file $2. Return: $value"
	echo -n "${value:-default}"
}

POL_Wine_CustomConvertRegPathToLinuxPrefix()
{
	# Convert a windows registry path info to a linux path inside prefix
	# Needs : POL_Wine_SelectPrefix - POL_Wine_PrefixCreate
	# Usage : POL_Wine_CustomConvertRegPathToLinuxPrefix Path
	# Returns : linux path inside prefix
	# Example : POL_Wine_CustomConvertRegPathToLinuxPrefix "C:\\Program Files\\Fox\\No One Lives Forever 2"
	
	[ -z "$WINEPREFIX" ] && POL_Debug_Fatal "WINEPREFIX not set"
	[ -z "$1" ] && POL_Debug_Fatal "Need PATH as only argument"
	local path
	# TODO : add drive letter substitution
	path="${1/C:\\\\/drive_c/}"
	path="$WINEPREFIX/${path//\\\\//}"
	echo -n "$path"
}

POL_Wine_Custom16bitSubsystemEnabled()
{
	# Test if linux kernel 16bit subsystem is available (since kernel 3.14 and some backported kernels from 3.14 e.g.: 3.13 in ubuntu 14.04)
	# Needs : nothing
	# Usage : POL_Wine_16bitSubsystemEnabled
	# Returns : true if enabled, false if not
	# Example : POL_Wine_16bitSubsystemEnabled
	
	local _16BIT
	_16BIT="$(cat /proc/sys/abi/ldt16)"
	[ $? -eq 0 ] && return true
	[ "$_16BIT" = "1" ] && return true
	return false
}

POL_Wine_CustomEnable16bitSubsystem()
{
	# Enable linux kernel 16bit subsystem
	# Needs : nothing
	# Usage : POL_Wine_CustomEnable16bitSubsystem
	# Returns : true if it worked, false if not
	# Example : POL_Wine_CustomEnable16bitSubsystem
	
	POL_Call POL_Function_RootCommand "sudo sysctl -w abi.ldt16=1; exit"
	[ $? -eq 0 ] && return true
	return false
}

POL_Wine_CustomDisable16bitSubsystem()
{
	# Disable linux kernel 16bit subsystem
	# Needs : nothing
	# Usage : POL_Wine_CustomDisable16bitSubsystem
	# Returns : true if it worked, false if not
	# Example : POL_Wine_CustomDisable16bitSubsystem
	
	POL_Call POL_Function_RootCommand "sudo sysctl -p; exit"
	[ $? -eq 0 ] && return true
	return false
}

POL_RogueSquadron3D_SetGlideOn()
{
	# Sets Rogue Squadron 3D Renderer to Glide in registry
	# Needs : POL_Wine_SelectPrefix - POL_Wine_PrefixCreate - POL_System_TmpCreate
	# Usage : POL_RogueSquadron3D_SetGlideOn
	# Returns : nothing
	# Example : POL_RogueSquadron3D_SetGlideOn
	
	[ -z "$WINEPREFIX" ] && POL_Debug_Fatal "WINEPREFIX not set"
	[ -z "$POL_System_TmpDir" ] && POL_Debug_Fatal "TEMP DIR not set"
	local regfile
	regfile="$POL_System_TmpDir/rs3d_glide.reg"
	echo "[HKEY_LOCAL_MACHINE\\Software\\LucasArts Entertainment Company LLC\\Rogue Squadron\\v1.0]" > regfile
	echo "\"3DSetup\"=\"TRUE\"" >> regfile
	echo "\"VDEVICE\"=\"Voodoo (Glide)\"" >> regfile
	regedit regfile
	rm -f regfile
}

POL_GetSetupImages "$SERVER/$PREFIX/images/top.jpg" "$SERVER/$PREFIX/images/left.jpg" "$TITLE"
POL_SetupWindow_Init

POL_Debug_Init

POL_SetupWindow_presentation "$TITLE" "LucasArts" "http://www.starwars.com/games-apps" "med_freeman" "$PREFIX"

POL_System_SetArch "$WINE_ARCH"
POL_System_TmpCreate "$PREFIX"
POL_Wine_SelectPrefix "$PREFIX"
POL_Wine_PrefixCreate "$WINE_VERSION"

POL_SetupWindow_cdrom
POL_SetupWindow_check_cdrom "rogue/rogue\ squadron.exe"

_16BITENABLED="$(POL_Wine_Custom16bitSubsystemEnabled)"
if [ "$_16BITENABLED" = false ]; then
	POL_Wine_CustomEnable16bitSubsystem
fi

POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$CDROM/setup.exe"
POL_Wine_WaitExit "$TITLE"

# Get game language and installation directory
POL_Wine_CustomExportRegistryKey "HKEY_LOCAL_MACHINE\Software\LucasArts Entertainment Company LLC\Rogue Squadron\v1.0" "rs3d.reg"
GAME_INSTALLDIR="$(POL_Wine_CustomGetRegValue "Install Path" "rs3d.reg")"
GAME_INSTALLDIR="$(POL_Wine_CustomConvertRegPathToLinuxPrefix "$GAME_INSTALLDIR")"

# Update 1.2 installation
POL_SetupWindow_message "$TITLE : $(eval_gettext 'Installation of update 1.21')" "$TITLE"

POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL"
if [ "$INSTALL_METHOD" = "LOCAL" ]; then
    cd "$HOME"
    POL_SetupWindow_browse "$(eval_gettext 'Please select the 1.21 update executable')" "$TITLE"
    UPDATE_EXE="$APP_ANSWER"
elif [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
    cd "$POL_System_TmpDir"
    UPDATE_EXE="rogueupd121.exe"
    POL_Download "$SERVER/$PREFIX/updates/$UPDATE_EXE" "e90984f2e3721fe72e67609aabd6db23"
fi
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$UPDATE_EXE"
POL_Wine_WaitExit "$TITLE"

if [ "$_16BITENABLED" = false ]; then
	POL_Wine_CustomDisable16bitSubsystem
fi

POL_Call POL_Install_directx9
POL_Call POL_Install_dxdiag
POL_Call POL_Install_dsound
POL_Wine_OverrideDLL "native" "dsound"
POL_Call POL_Install_directmusic

cd "$GAME_INSTALLDIR"
MISSIONFIX_EXE="RS3Dmissionfix.exe"
POL_Download "$SERVER/$PREFIX/fix/$MISSIONFIX_EXE" "64936846991dc1bcd0b5054e0ee2d3d6"
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$MISSIONFIX_EXE"
POL_Wine_WaitExit "$TITLE"

cd "$POL_System_TmpDir"
NGLIDE_EXE="nGlide102_setup.exe"
POL_Download "http://www.zeus-software.com/files/nglide/$NGLIDE_EXE" "3753dd73587af332ad72e7fb73545ab1"
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$NGLIDE_EXE"
POL_Wine_WaitExit "$TITLE"

POL_RogueSquadron3D_SetGlideOn

Set_Managed "Off"
POL_Wine_X11Drv "Decorated" "N"
POL_Wine_X11Drv "GrabFullscreen" "Y"
Set_OS "win98"

POL_Shortcut "ROGUE.exe" "$TITLE"
POL_Shortcut "windows/system32/nglide_config.exe" "$TITLE - Graphic settings"
cd "$GAME_INSTALLDIR"
POL_Download "$SERVER/$PREFIX/manual/Manual.pdf" "bbd6697b86ecad0c033525c1502e38b0"
POL_Shortcut_Document "$TITLE" "$GAME_INSTALLDIR/Manual.pdf"

POL_SetupWindow_message "$(eval_gettext '$TITLE has been successfully installed.')"

POL_System_TmpDelete
POL_SetupWindow_Close
exit 0
