#!/bin/bash
# Date : (2014-09-18 00:12)
# Last revision : (2014-09-28 16:43)
# Wine version used : 1.7.26
# Distribution used to test : Ubuntu 14.04 Trusty x64 + Debian 7.0 Wheezy x64
# Author : med_freeman
# Licence : Retail

[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"

TITLE="Rogue Squadron 3D"
PREFIX="RogueSquadron3D"
WINE_VERSION="1.7.26"
WINE_ARCH="x86"
AUTHOR="med_freeman"

POL_GetSetupImages "http://files.playonlinux.com/resources/setups/$PREFIX/top.jpg" "http://files.playonlinux.com/resources/setups/$PREFIX/left.jpg" "$TITLE"
POL_SetupWindow_Init

POL_Debug_Init

POL_SetupWindow_presentation "$TITLE" "LucasArts" "http://www.starwars.com/games-apps" "$AUTHOR" "$PREFIX"

POL_System_SetArch "$WINE_ARCH"
POL_System_TmpCreate "$PREFIX"
POL_Wine_SelectPrefix "$PREFIX"
POL_Wine_PrefixCreate "$WINE_VERSION"

POL_SetupWindow_cdrom
POL_SetupWindow_check_cdrom "rogue/rogue\ squadron.exe"

# Downloading installer
cd "$POL_System_TmpDir"
INSTALL_EXE="RS3DInstaller.exe"
POL_Download "http://ftp.oktopod.tv/POL/$PREFIX/installer/$INSTALL_EXE" "f936b30fc8962c99d0413f51b36dcfb9"

# Running installer
POL_Wine_WaitBefore "$TITLE"
POL_Wine start /unix "$INSTALL_EXE" "/nocdprompt"
POL_Wine_WaitExit "$TITLE"

# Mandatory dependencies
POL_Call POL_Install_dxdiag
POL_Call POL_Install_dsound
POL_Wine_OverrideDLL "native" "dsound"

# Needed Overrides
Set_Managed "Off"
POL_Wine_X11Drv "Decorated" "N"
POL_Wine_X11Drv "GrabFullscreen" "Y"
Set_OS "win98"

# Shortcuts
POL_Shortcut "ROGUE.exe" "$TITLE"
POL_Shortcut "windows/system32/nglide_config.exe" "$TITLE - Graphic settings"

# Set reg file name
REG_FILE="rs3d.reg"
# Export registry to file
regedit /E "$POL_System_TmpDir/$REG_FILE" "HKEY_LOCAL_MACHINE\Software\LucasArts Entertainment Company LLC\Rogue Squadron\v1.0"
# Get game installation directory
[ -e "$POL_System_TmpDir/$REG_FILE" ] && GAME_INSTALLDIR="$(grep "Install Path" "$POL_System_TmpDir/$REG_FILE" | head -n 1 | tr -d '"' | cut -d= -f2 | tr -d '\015')"

# Convert it to wine path
if [ -n "$GAME_INSTALLDIR" ]; then
    GAME_INSTALLDIR="${GAME_INSTALLDIR/C:\\\\/drive_c/}"
    GAME_INSTALLDIR="$WINEPREFIX/${GAME_INSTALLDIR//\\\\//}"

    cd "$GAME_INSTALLDIR"
    POL_Download "http://ftp.oktopod.tv/POL/$PREFIX/manual/Manual.pdf" "bbd6697b86ecad0c033525c1502e38b0"
    POL_Shortcut_Document "$TITLE" "$GAME_INSTALLDIR/Manual.pdf"
fi

POL_SetupWindow_message "$(eval_gettext '$TITLE has been successfully installed.')"

POL_System_TmpDelete
POL_SetupWindow_Close
exit 0
