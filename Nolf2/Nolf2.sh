#!/bin/bash
# Date : (2014-09-10 20-41)
# Last revision : (2014-09-20 02:58)
# Wine version used : 1.5.22-vertex-blending-1.5.21
# Distribution used to test : Ubuntu 14.04 Trusty x64 - Debian 7 Wheezy x64
# Author : med_freeman
# Licence : Retail

[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"

TITLE="No One Lives Forever 2"
PREFIX="Nolf2"
WINE_VERSION="1.5.22-vertex-blending-1.5.21"
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
	regedit /E $POL_System_TmpDir/$2 "$1"
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
	# TODO : add driver letter substitution
	path="${1/C:\\\\/drive_c/}"
	path="$WINEPREFIX/${path//\\\\//}"
	echo -n "$path"
}

POL_Nolf2_SetLanguage()
{
	# Sets Nolf2 language in registry
	# Needs : POL_Wine_SelectPrefix - POL_Wine_PrefixCreate - POL_System_TmpCreate
	# Usage : POL_Nolf2SetLanguage LanguageCode
	# Returns : nothing
	# Example : POL_Nolf2SetLanguage "EN"
	
	[ -z "$WINEPREFIX" ] && POL_Debug_Fatal "WINEPREFIX not set"
	[ -z "$POL_System_TmpDir" ] && POL_Debug_Fatal "TEMP DIR not set"
	[ -z "$1" ] && POL_Debug_Fatal "Need LANG CODE as only argument"
	local regfile
	regfile="$POL_System_TmpDir/nolf2_lang.reg"
	echo "[HKEY_LOCAL_MACHINE\\Software\\Monolith Productions\\No One Lives Forever 2\\1.0]" > regfile
	echo "\"NetRegionCode\"=\"$1\"" >> regfile
	regedit regfile
	rm -f regfile
}

POL_GetSetupImages "$SERVER/$PREFIX/images/top.jpg" "$SERVER/$PREFIX/images/left.jpg" "$TITLE"
POL_SetupWindow_Init

POL_Debug_Init

POL_SetupWindow_presentation "$TITLE" "Sierra Entertainment" "http://www.sierra.com/" "med_freeman" "$PREFIX"

POL_System_SetArch "$WINE_ARCH"
POL_System_TmpCreate "$PREFIX"
POL_Wine_SelectPrefix "$PREFIX"
POL_Wine_PrefixCreate "$WINE_VERSION"

POL_SetupWindow_cdrom
POL_SetupWindow_check_cdrom "Data/GAME.REZ"

POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$CDROM/Setup.exe"
POL_Wine_WaitExit "$TITLE"
POL_Wine_reboot

# Get game language and installation directory
POL_Wine_CustomExportRegistryKey "HKEY_LOCAL_MACHINE\Software\Monolith Productions\No One Lives Forever 2\1.0" "nolf2.reg"
GAME_LANG="$(POL_Wine_CustomGetRegValue "NetRegionCode" "nolf2.reg")"
GAME_INSTALLDIR="$(POL_Wine_CustomGetRegValue "InstallDir" "nolf2.reg")"
GAME_INSTALLDIR="$(POL_Wine_CustomConvertRegPathToLinuxPrefix "$GAME_INSTALLDIR")"

# Update 1.3 installation
POL_SetupWindow_message "$TITLE : $(eval_gettext 'Installation of update 1.3 $GAME_LANG')" "$TITLE"

POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL"
if [ "$INSTALL_METHOD" = "LOCAL" ]; then
    cd "$HOME"
    POL_SetupWindow_browse "$(eval_gettext 'Please select the 1.3 update executable')" "$TITLE"
    UPDATE_EXE="$APP_ANSWER"
elif [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
    cd "$POL_System_TmpDir"
    if [ "$GAME_LANG" = "EN" ]; then
		UPDATE_EXE="nolf2_update_en_13.exe"
        POL_Download "$SERVER/$PREFIX/updates/$UPDATE_EXE" "a9a1cb0447ec53c1b4b5db6b4e30a3b5"
    elif [ "$GAME_LANG" = "FR" ]; then
		UPDATE_EXE="nolf2_update_fr_13.exe"
        POL_Download "$SERVER/$PREFIX/updates/$UPDATE_EXE" "cf1718cf2e1001bd4ef71f670da6365f"
    elif [ "$GAME_LANG" = "DE" ]; then
		UPDATE_EXE="nolf2_update_de_13.exe"
        POL_Download "$SERVER/$PREFIX/updates/$UPDATE_EXE" "dd5d9339f061498d2bb3e22275584ec0"
    elif [ "$GAME_LANG" = "IT" ]; then
		UPDATE_EXE="nolf2_update_it_13.exe"
        POL_Download "$SERVER/$PREFIX/updates/$UPDATE_EXE" "7bed1c642f4e8d6db766a4d13c47d1dd"
    elif [ "$GAME_LANG" = "ES" ]; then
		UPDATE_EXE="nolf2_update_es_13.exe"
        POL_Download "$SERVER/$PREFIX/updates/$UPDATE_EXE" "b391b35c0f0971e341d0313d2cc8570d"
    elif [ "$GAME_LANG" == "JP" ]; then
		# since i can't find the japanese patch, set the language as english and install the english patch
		POL_Nolf2_SetLanguage "EN"
		UPDATE_EXE="nolf2_update_en_13.exe"
        POL_Download "$SERVER/$PREFIX/updates/$UPDATE_EXE" "a9a1cb0447ec53c1b4b5db6b4e30a3b5"
    fi
fi
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$UPDATE_EXE"
POL_Wine_WaitExit "$TITLE"

# Set back language to japanese in case of auto-updating japanese version with english patch
if [ "$INSTALL_METHOD" = "DOWNLOAD" ] && [ "$GAME_LANG" == "JP" ]; then
	POL_Nolf2_SetLanguage "JP"
fi

# Need VCRUN6
POL_Call POL_Install_vcrun6

# Need VCRUN2005 for msvcirt.dll
POL_Call POL_Install_vcrun2005

# Fixes a bug
cp "$WINEPREFIX/drive_c/windows/system32/msvcirt.dll" "$GAME_INSTALLDIR/"

POL_Call POL_Install_directx9

POL_Call POL_Install_dsound
POL_Wine_OverrideDLL "native" "dsound"

POL_Call POL_Install_directmusic

# Need DOTNET20 for mscoree and streamci, for directmusic
POL_Call POL_Install_dotnet20
POL_Wine_OverrideDLL "native" "mscoree"
POL_Wine_OverrideDLL "native" "streamci"

POL_SetupWindow_question "$(eval_gettext 'Do you want to install Map Pack #1 ?')" "$TITLE"
if [ "$APP_ANSWER" = "TRUE" ]; then
	POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL"
	if [ "$INSTALL_METHOD" = "LOCAL" ]; then
		cd "$HOME"
		POL_SetupWindow_browse "$(eval_gettext 'Please select the Map Pack #1 executable')" "$TITLE"
		UPDATE_EXE="$APP_ANSWER"
	elif [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
		cd "$POL_System_TmpDir"
		UPDATE_EXE="nolf2_mappack1.exe"
		POL_Download "$SERVER/$PREFIX/mappacks/$UPDATE_EXE" "51d000db97efd796a9d6e75e7982f6eb"
	fi
	# Set language as english to allow mappack install, then revert to standard
	if [ "$GAME_LANG" -ne "EN" ]; then
		POL_Nolf2_SetLanguage "EN"
	fi
	POL_Wine_WaitBefore "$TITLE"
	POL_Wine start /unix "$UPDATE_EXE"
	POL_Wine_WaitExit "$TITLE"
	if [ "$GAME_LANG" -ne "EN" ]; then
		POL_Nolf2_SetLanguage "$GAME_LANG"
	fi
fi

POL_SetupWindow_question "$(eval_gettext 'Do you want to install Map Pack #2 ?')" "$TITLE"
if [ "$APP_ANSWER" = "TRUE" ]; then
	POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL"
	if [ "$INSTALL_METHOD" = "LOCAL" ]; then
		cd "$HOME"
		POL_SetupWindow_browse "$(eval_gettext 'Please select the Map Pack #2 executable')" "$TITLE"
		UPDATE_EXE="$APP_ANSWER"
	elif [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
		cd "$POL_System_TmpDir"
		UPDATE_EXE="nolf2_mappack2.exe"
		POL_Download "$SERVER/$PREFIX/mappacks/$UPDATE_EXE" "8a8b8ab231e7dd3287e903d34363cd6a"
	fi
	# Set language as english to allow mappack install, then revert to standard
	if [ "$GAME_LANG" -ne "EN" ]; then
		POL_Nolf2_SetLanguage "EN"
	fi
	POL_Wine_WaitBefore "$TITLE"
	POL_Wine start /unix "$UPDATE_EXE"
	POL_Wine_WaitExit "$TITLE"
	if [ "$GAME_LANG" -ne "EN" ]; then
		POL_Nolf2_SetLanguage "$GAME_LANG"
	fi
fi

Set_Managed "On"

POL_Shortcut "NOLF2.exe" "$TITLE"
cd "$GAME_INSTALLDIR"
POL_Download "$SERVER/$PREFIX/manual/Manual.pdf" "7e1162f2e2c9bb5d6eeb6d98288b0e96"
POL_Shortcut_Document "$TITLE" "$GAME_INSTALLDIR/Manual.pdf"
POL_Shortcut "NOLF2Srv.exe" "Nolf2 Dedicated Server"

POL_SetupWindow_message "$(eval_gettext '$TITLE has been successfully installed.')"

POL_System_TmpDelete
POL_SetupWindow_Close
exit
