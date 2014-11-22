#!/bin/bash
# Date : (2014-10-08 23:39)
# Date : (2014-10-08 00:36)
# Wine version used : 1.7.31
# Distribution used to test : Ubuntu 14.04 Trusty x64 + Debian 7.0 Wheezy x64
# Author : med_freeman
# Licence : Retail
# Requires : Lame
# Only For : http://www.playonlinux.com
 
[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"
 
TITLE="GOG.com - POD Gold"
PREFIX="PodGold_gog"
GOGID="pod_gold"
EDITOR="Ubisoft"
GAME_URL="http://www.ubi.com"
AUTHOR="med_freeman"
WINE_VERSION="1.7.31"
WINE_ARCH="x86"
 
POL_GetSetupImages "http://files.playonlinux.com/resources/setups/$PREFIX/top.jpg" "http://files.playonlinux.com/resources/setups/$PREFIX/left.jpg" "$TITLE"
POL_SetupWindow_Init
POL_SetupWindow_SetID 2296
 
POL_Debug_Init
 
POL_SetupWindow_presentation "$TITLE" "$EDITOR" "$GAME_URL" "$AUTHOR" "$PREFIX"
 
# Download / Select GOG setup
POL_Call POL_GoG_setup "$GOGID" "3e1467e236870cb9ab5994dbaaa29b7d"
 
POL_System_SetArch "$WINE_ARCH"
POL_System_TmpCreate "$PREFIX"
POL_Wine_SelectPrefix "$PREFIX"
POL_Wine_PrefixCreate "$WINE_VERSION"
 
# Install GOG setup
POL_Call POL_GoG_install

GAMEDIR="$GOGROOT/POD GOLD"

# Needed for video
sed -i '/[drivers32]/a vidc.IV41=ir41_32.dll' $WINEPREFIX/drive_c/windows/system.ini
# Needed for music
lame --decode "$GAMEDIR/Track02.mp3"

POL_SetupWindow_message "$(eval_gettext 'We will now install nGlide and Podhacks, allowing the game to exit properly, providing graphics improvements and compatibility fixes.')" "$TITLE"

# Install nGlide wrapper
cd "$POL_System_TmpDir"
NGLIDE_EXE="nGlide103_setup.exe"
POL_Download "http://www.zeus-software.com/files/nglide/$NGLIDE_EXE" "938182d383c08e5caaf9a83de13b1f2a"
POL_Wine start /unix "$NGLIDE_EXE"
POL_Wine_WaitExit "$TITLE"

# Install PodHacks
cd "$GAMEDIR"
PODHACKS_EXE="PodHacks.exe"
POL_Download "http://svn.nicode.net/podhacks/bin/$PODHACKS_EXE?revision=75" "e7b0e67b2540b69082be015b012d55ed"
mv "$PODHACKS_EXE?revision=75" $PODHACKS_EXE
POL_Wine_WaitBefore "$TITLE"
POL_Wine start "$PODHACKS_EXE --install"

# Move gog glide 2x so the game can work with nglide
mv glide2x.dll glide2x_gog.dll

# Shortcuts
SHORTCUT="POD Gold"
POL_Shortcut "PODX3Dfx.exe" "$SHORTCUT" "" "" "Game;RacingGame;"
POL_Shortcut "nglide_config.exe" "$SHORTCUT - Graphic settings"
POL_Shortcut_Document "$SHORTCUT" "$GAMEDIR/manual.pdf"

POL_System_TmpDelete
POL_SetupWindow_Close
exit 0
