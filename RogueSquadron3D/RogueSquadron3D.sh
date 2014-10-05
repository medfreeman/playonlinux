#!/bin/bash
# Date : (2014-09-18 00:12)
# Last revision : (2014-10-05 06:15)
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

POL_SetupWindow_cdrom
POL_SetupWindow_check_cdrom "rogue/rogue\ squadron.exe"

# Downloading installer
cd "$POL_System_TmpDir"
INSTALL_EXE="RS3DInstaller-0.92_nglide_102.exe"
POL_Download "http://ftp.oktopod.tv/POL/$PREFIX/installer/$INSTALL_EXE" "f6e3538984ce7ea13423c755b35f180e"

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
POL_Wine_Direct3D "StrictDrawOrdering" "enabled"
Set_OS "win98"

# Shortcuts
POL_Shortcut "ROGUE.exe" "$TITLE"
POL_Shortcut "nglide_config.exe" "$TITLE - Graphic settings"

GAME_INSTALLDIR="$WINEPREFIX/drive_c/Program Files/LucasArts/ROGUE"
cd "$GAME_INSTALLDIR"
POL_Download "http://ftp.oktopod.tv/POL/$PREFIX/manual/Manual.pdf" "bbd6697b86ecad0c033525c1502e38b0"
POL_Shortcut_Document "$TITLE" "$GAME_INSTALLDIR/Manual.pdf"

POL_SetupWindow_message "$(eval_gettext '$TITLE has been successfully installed.')"

POL_System_TmpDelete
POL_SetupWindow_Close
exit 0
