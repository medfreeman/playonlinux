#!/bin/bash
# Date : (2014-09-24 01:30)
# Last revision : (2014-11-22 20:12)
# Wine version used : 1.7.14-imm32_bug35361
# Distribution used to test : Ubuntu 14.04 Trusty x64
# Author : med_freeman (from GNU_Raziel RaymanOrigins)
# Licence : Retail
# Only For : http://www.playonlinux.com
 
[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"
 
TITLE="Rayman Legends"
TITLE_DEMO="Rayman Legends (Demo)"
PREFIX="RaymanLegends"
EDITOR="Ubisoft"
GAME_URL="http://rayman.ubi.com/legends/"
AUTHOR="GNU_Raziel + med_freeman"
WORKING_WINE_VERSION="1.7.14-imm32_bug35361" # Allows steam overlay to work without crash
GAME_VMS="512"
 
# Starting the script
POL_GetSetupImages "http://files.playonlinux.com/resources/setups/RaymanLegends/top.jpg" "http://files.playonlinux.com/resources/setups/RaymanLegends/left.jpg" "$TITLE"
POL_SetupWindow_Init
POL_SetupWindow_SetID 2283
 
# Starting debugging API
POL_Debug_Init
 
POL_SetupWindow_presentation "$TITLE" "$EDITOR" "$GAME_URL" "$AUTHOR" "$PREFIX"
 
# Setting prefix path
POL_Wine_SelectPrefix "$PREFIX"
 
# Downloading wine if necessary and creating prefix
POL_System_SetArch "x86" # for uplay
POL_Wine_PrefixCreate "$WORKING_WINE_VERSION"
 
# Choose between DVD and Digital Download version
POL_SetupWindow_InstallMethod "STEAM_DEMO,DVD,STEAM,LOCAL"

# Installing mandatory dependencies
if [ "$INSTALL_METHOD" == "STEAM" ] || [ "$INSTALL_METHOD" == "STEAM_DEMO" ]; then
        POL_Wine_OverrideDLL "" "dwrite" # Needed fix or we get invisible fonts in steam
        POL_Call POL_Install_steam
fi
POL_Call POL_Install_dxfullsetup
# Uplay dependencies
# Install crypt32
POL_Call POL_Install_crypt32
POL_Wine_OverrideDLL "builtin" "crypt32"
POL_Wine_OverrideDLL_App "Uplay.exe" "native" "crypt32"
# Install gdiplus
POL_Call POL_Install_gdiplus
POL_Wine_OverrideDLL "builtin" "gdiplus"
POL_Wine_OverrideDLL_App "Uplay.exe" "native" "gdiplus"
# Install vcrun2008sp1
POL_Call POL_Install_vcrun2008

# Mandatory settings for Digital version
[ "$INSTALL_METHOD" == "STEAM_DEMO" ] && { STEAM_ID="243340"; SHORTCUT_NAME="$TITLE_DEMO"; }
[ "$INSTALL_METHOD" == "STEAM" ] && { STEAM_ID="242550"; SHORTCUT_NAME="$TITLE"; }
 
# Asking about memory size of graphic card
POL_SetupWindow_VMS $GAME_VMS
 
# Set Graphic Card information keys for wine
POL_Wine_SetVideoDriver
 
# Sound problem fix - pulseaudio related
[ "$POL_OS" = "Linux" ] && Set_SoundDriver "alsa"
[ "$POL_OS" = "Linux" ] && Set_SoundEmulDriver "Y"
## End Fix
 
## Begin Common PlayOnMac Section ##
[ "$POL_OS" = "Mac" ] && Set_Managed "Off"
## End Section ##
 
# Begin installation
if [ "$INSTALL_METHOD" == "DVD" ]; then
        # Asking for CDROM and checking if it's correct one
        POL_SetupWindow_message "$(eval_gettext 'Please select the setup file to run')" "$TITLE"
        POL_SetupWindow_cdrom
        POL_SetupWindow_check_cdrom "Rayman.ico"
        POL_Wine start /unix "$CDROM/setup.exe"
        POL_Wine_WaitExit "$TITLE"
elif [ "$INSTALL_METHOD" == "STEAM_DEMO" ] || [ "$INSTALL_METHOD" == "STEAM" ]; then
        # Mandatory pre-install fix for steam
        POL_Call POL_Install_steam_flags "$STEAM_ID"
        # Shortcut done before install for steam version
        POL_Shortcut "steam.exe" "$SHORTCUT_NAME" "$TITLE.png" "steam://rungameid/$STEAM_ID"
        # Steam install
        POL_SetupWindow_message "$(eval_gettext 'When $TITLE download by Steam is finished,\nDo NOT click on Play.\n\nClose COMPLETELY the Steam interface, \nso that the installation script can continue')" "$TITLE"
        cd "$WINEPREFIX/drive_c/$PROGRAMFILES/Steam"
        POL_Wine start /unix "steam.exe" steam://install/$STEAM_ID
        POL_Wine_WaitExit "$TITLE"
else
        # Asking then installing DDV of the game
        cd "$HOME"
        POL_SetupWindow_browse "$(eval_gettext 'Please select the setup file to run')" "$TITLE"
        SETUP_EXE="$APP_ANSWER"
        POL_Wine start /unix "$SETUP_EXE"
        POL_Wine_WaitExit "$TITLE"
fi
 
# Making shortcut
if [ "$INSTALL_METHOD" != "STEAM_DEMO" ] && [ "$INSTALL_METHOD" != "STEAM" ]; then
        POL_Shortcut "Rayman Legends.exe" "$TITLE" "$TITLE.png" ""
fi

POL_SetupWindow_message "$(eval_gettext '$TITLE has been successfully installed.')"
 
POL_SetupWindow_Close
exit 0
