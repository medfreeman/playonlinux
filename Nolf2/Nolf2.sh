#!/bin/bash
# Date : (2014-09-10 20-41)
# Last revision : (2015-05-20 19:54)
# Wine version used : 1.5.22-vertex-blending-1.5.21
# Distribution used to test : Ubuntu 14.04 Trusty x64 - Debian 7 Wheezy x64
# Author : med_freeman
# Licence : Retail
# Only For : http://www.playonlinux.com

[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"

TITLE="No One Lives Forever 2"
PREFIX="Nolf2"
EDITOR="Fox Interactive"
GAME_URL="http://www.lith.com/Games/No-One-Lives-Forever-2"
AUTHOR="med_freeman"
WINE_VERSION="1.5.22-vertex-blending-1.5.21"
WINE_ARCH="x86"

POL_GetSetupImages "http://files.playonlinux.com/resources/setups/$PREFIX/top.jpg" "http://files.playonlinux.com/resources/setups/$PREFIX/left.jpg" "$TITLE"
POL_SetupWindow_Init

POL_Debug_Init

POL_SetupWindow_presentation "$TITLE" "$EDITOR" "$GAME_URL" "$AUTHOR" "$PREFIX"

POL_SetupWindow_cdrom
POL_SetupWindow_check_cdrom "Data/GAME.REZ"

POL_System_SetArch "$WINE_ARCH"
POL_System_TmpCreate "$PREFIX"
POL_Wine_SelectPrefix "$PREFIX"
POL_Wine_PrefixCreate "$WINE_VERSION"

POL_Wine_WaitBefore "$TITLE"
POL_Wine "$CDROM/Setup.exe"
POL_Wine_reboot

# Update 1.3 installation - needed for sounds to work properly
POL_SetupWindow_message "$TITLE : $(eval_gettext 'Installation of update 1.3')" "$TITLE"

POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL"
if [ "$INSTALL_METHOD" = "LOCAL" ]; then
    cd "$HOME"
    POL_SetupWindow_browse "$(eval_gettext 'Please select the 1.3 update executable corresponding to your language')" "$TITLE"
    UPDATE_EXE="$APP_ANSWER"
elif [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
    POL_SetupWindow_menu "Please select your game language" "$TITLE" "English~Français~Deutsch~Español~Italiano" "~"
    cd "$POL_System_TmpDir"
    if [ "$APP_ANSWER" = "English" ]; then
        UPDATE_URL="303-no-one-lives-forever-2-a-spy-in-harms-way-english-patch/"
        MD5="ffa002f8f5b08496fd7e6e9767da168c"
        UPDATE_ZIP="nolf2_update_en_13.zip"
        UPDATE_EXE="nolf2-update_1x3.exe"
    elif [ "$APP_ANSWER" = "Français" ]; then
        UPDATE_URL="304-no-one-lives-forever-2-a-spy-in-harms-way-french-patch/"
        MD5="020d09ef78ab2f0b39fda2dae8abbc55"
        UPDATE_ZIP="nolf2_update_fr_13.zip"
        UPDATE_EXE="nolf2_update_fr_13.exe"
    elif [ "$APP_ANSWER" = "Deutsch" ]; then
        UPDATE_URL="305-no-one-lives-forever-2-a-spy-in-harms-way-german-patch/"
        MD5="077389682845b6d67bca5884a4a38ae9"
        UPDATE_ZIP="nolf2_update_de_13.zip"
        UPDATE_EXE="nolf2_update_de_13.exe"
    elif [ "$APP_ANSWER" = "Español" ]; then
        UPDATE_URL="307-no-one-lives-forever-2-a-spy-in-harms-way-spanish-patch/"
        MD5="db3fa8bde7f6113ac1e84f09bd666473"
        UPDATE_ZIP="nolf2_update_es_13.zip"
        UPDATE_EXE="nolf2_update_es_13.exe"
    elif [ "$APP_ANSWER" = "Italiano" ]; then
        UPDATE_URL="306-no-one-lives-forever-2-a-spy-in-harms-way-italian-patch/"
        MD5="fb4c455cf16e23a80d154d54c8355651"
        UPDATE_ZIP="nolf2_update_it_13.zip"
        UPDATE_EXE="nolf2_update_it_13.exe"
    fi
    POL_Call POL_PCGamingWiki_Download "$UPDATE_URL" "$POL_System_TmpDir/$UPDATE_ZIP" "No One Lives Forever 2 Patch 1.3 - $APP_ANSWER" "$MD5"
    unzip -j "$UPDATE_ZIP"
fi

POL_Wine_WaitBefore "$TITLE"
POL_Wine "$UPDATE_EXE"

GAMEDIR="$WINEPREFIX/drive_c/$PROGRAMFILES/Fox/No One Lives Forever 2"

# Need VCRUN6
POL_Call POL_Install_vcrun6

# Need VCRUN2005 for msvcirt.dll
POL_Call POL_Install_vcrun2005

# Fixes a bug
cp "$WINEPREFIX/drive_c/windows/system32/msvcirt.dll" "$GAMEDIR/"

POL_Call POL_Install_directx9

POL_Call POL_Install_dsound
POL_Wine_OverrideDLL "native" "dsound"

POL_Call POL_Install_directmusic

# Need DOTNET20 for mscoree and streamci, for directmusic
POL_Call POL_Install_dotnet20
POL_Wine_OverrideDLL "native" "mscoree"
POL_Wine_OverrideDLL "native" "streamci"

Set_Managed "On"

POL_Shortcut "NOLF2.exe" "$TITLE" "" "" "Game;Shooter;"
POL_Shortcut "NOLF2Srv.exe" "Nolf2 Dedicated Server"

POL_System_TmpDelete
POL_SetupWindow_Close
exit 0
