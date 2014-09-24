#!/bin/bash
# Date : (2010-07-11 21:00)
# Last revision : (2014-09-24 01:30)
# Wine version used : 1.3.7, 1.3.15, 1.3.23, 1.4, 1.7.14-imm32_bug35361
# Distribution used to test : Ubuntu 14.04 Trusty x64
# Author : GNU_Raziel
# Licence : Retail
# Only For : http://www.playonlinux.com
 
[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"
 
TITLE="Star Wars : The Force Unleashed - Ultimate Sith Edition"
PREFIX="swtfu"
EDITOR="LucasArts"
GAME_URL="http://www.lucasarts.com/games/theforceunleashed/"
AUTHOR="GNU_Raziel"
WORKING_WINE_VERSION="1.7.14-imm32_bug35361"
GAME_VMS="256"
 
if [ "$POL_LANG" == "fr" ]; then
TITLE="Star Wars : Le Pouvoir de la Force - Ultimate Sith Edition"
fi
 
# Starting the script
POL_GetSetupImages "http://files.playonlinux.com/resources/setups/swtfu/top.jpg" "http://files.playonlinux.com/resources/setups/swtfu/left.jpg" "$TITLE"
POL_SetupWindow_Init
 
# Starting debugging API
POL_Debug_Init
 
POL_SetupWindow_presentation "$TITLE" "$EDITOR" "$GAME_URL" "$AUTHOR" "$PREFIX"
 
# Setting prefix path
POL_Wine_SelectPrefix "$PREFIX"
 
# Downloading wine if necessary and creating prefix
POL_System_SetArch "x86" # For dotnet/mono
POL_Wine_PrefixCreate "$WORKING_WINE_VERSION"
 
# Choose between DVD and Digital Download version
POL_SetupWindow_InstallMethod "DVD,STEAM,LOCAL"
 
# Installing mandatory dependencies
if [ "$INSTALL_METHOD" == "STEAM" ]; then
        # Needed fix or we get invisible fonts in steam
        POL_Wine_OverrideDLL "" "dwrite"
        POL_Call POL_Install_steam
fi
POL_Call POL_Install_dxfullsetup
# .Net 3.5 SP1 for the launcher
POL_Call POL_Install_dotnet35sp1
 
# Mandatory setting for steam
[ "$INSTALL_METHOD" == "STEAM" ] && STEAM_ID="32430"
 
# Asking about memory size of graphic card
POL_SetupWindow_VMS $GAME_VMS
 
#Fix for this game
cd "$POL_USER_ROOT/tmp/"
cat << EOF > swtfu_fix.reg
[HKEY_LOCAL_MACHINE\\SYSTEM\\ControlSet001\\Control\\Session Manager\\Memory Management]
"ClearPageFileAtShutdown"=dword:00000000
"DisablePagingExecutive"=dword:00000000
"LargeSystemCache"=dword:00000000
"NonPagedPoolQuota"=dword:00000000
"NonPagedPoolSize"=dword:00000000
"PagedPoolQuota"=dword:00000000
"PagedPoolSize"=dword:00000000
"SecondLevelDataCache"=dword:00000000
"SystemPages"=dword:00000000
"PagingFiles"=hex(7):43,00,3a,00,5c,00,70,00,61,00,67,00,65,00,66,00,69,00,6c,\\
  00,65,00,2e,00,73,00,79,00,73,00,20,00,31,00,30,00,30,00,20,00,31,00,35,00,\\
  30,00,30,00,00,00,00,00
"PhysicalAddressExtension"=dword:00000000
"SessionViewSize"=dword:00000030
"SessionPoolSize"=dword:00000004
"WriteWatch"=dword:00000001
 
[HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management]
"ClearPageFileAtShutdown"=dword:00000000
"DisablePagingExecutive"=dword:00000000
"LargeSystemCache"=dword:00000000
"NonPagedPoolQuota"=dword:00000000
"NonPagedPoolSize"=dword:00000000
"PagedPoolQuota"=dword:00000000
"PagedPoolSize"=dword:00000000
"SecondLevelDataCache"=dword:00000000
"SystemPages"=dword:00000000
"PagingFiles"=hex(7):43,00,3a,00,5c,00,70,00,61,00,67,00,65,00,66,00,69,00,6c,\\
  00,65,00,2e,00,73,00,79,00,73,00,20,00,31,00,30,00,30,00,20,00,31,00,35,00,\\
  30,00,30,00,00,00,00,00
"PhysicalAddressExtension"=dword:00000000
"SessionViewSize"=dword:00000030
"SessionPoolSize"=dword:00000004
"WriteWatch"=dword:00000001
 
[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Cryptography\\RNG]
"Seed"=hex:ac,28,70,71,d1,c7,76,6e,33,06,81,61,85,59,1f,67,58,c1,88,11,b0,d7,\\
  43,04,40,43,af,73,d8,1f,c0,6b,73,cd,0c,72,2a,c4,e6,3c,1a,51,98,f3,e1,ad,0e,\\
  d8,9a,6a,86,7b,1e,e6,97,23,b1,61,3e,4e,97,73,9b,03,d8,78,dc,f6,f2,fb,1e,2b,\\
  a0,70,a0,97,2e,98,d7,17
EOF
POL_Wine regedit swtfu_fix.reg

# Second fix
# cat << EOF > swtfu_fix2.reg
# [HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management]
# "PagingFiles"=hex(7):43,00,3a,00,5c,00,70,00,61,00,67,00,65,00,66,00,69,00,6c,00,65,00,2e,00,73,00,79,00,73,00,20,00,31,00,30,00,30,00,20,00,31,00,35,00,30,00,30,00,00,00,00,00
# EOF
# POL_Wine regedit swtfu_fix2.reg
 
# Set Graphic Card informations keys for wine
POL_Wine_SetVideoDriver
 
# Sound problem fix - pulseaudio related
[ "$POL_OS" = "Linux" ] && Set_SoundDriver "alsa"
[ "$POL_OS" = "Linux" ] && Set_SoundEmulDriver "Y"
# End Fix
  
## PlayOnMac Section
[ "$POL_OS" = "Mac" ] && Set_Managed "Off"
## End Section
 
# Begin installation
if [ "$INSTALL_METHOD" == "DVD" ]; then
        # Asking for CDROM and checking if it's correct one
        POL_SetupWindow_message "$(eval_gettext 'Please insert the game media into your disk drive')" "$TITLE"
        POL_SetupWindow_cdrom
        POL_SetupWindow_check_cdrom "SWTFU_Autorun.exe"
        # Disk 1
        cd "$WINEPREFIX"/dosdevices
        ln -sf "$CDROM" p:
        POL_Wine start /unix "$CDROM/setup.exe"
        # Ejecting Disk 1
        POL_SetupWindow_message "$(eval_gettext 'When the game setup will ask for next Disk\nclick on \"Forward\"')" "$TITLE"
        POL_Wine eject
        # Disk 2
        POL_SetupWindow_message "$(eval_gettext 'Please insert the next game media into your disk drive')" "$TITLE"
        POL_SetupWindow_cdrom
        cd "$WINEPREFIX"/dosdevices
        ln -sf "$CDROM" p:
        POL_Wine_WaitExit "$TITLE"
elif [ "$INSTALL_METHOD" == "STEAM" ]; then
        # Mandatory pre-install fix for steam
        POL_Call POL_Install_steam_flags "$STEAM_ID"
        # Shortcut done before install for steam version
        POL_Shortcut "steam.exe" "$TITLE" "$TITLE.png" "steam://rungameid/$STEAM_ID"
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
  
# Cleaning temp
if [ -e "$WINEPREFIX/drive_c/windows/temp/" ]; then
        rm -rf "$WINEPREFIX/drive_c/windows/temp/"*
        chmod -R 777 "$POL_USER_ROOT/tmp/"
        rm -rf "$POL_USER_ROOT/tmp/"*
fi
 
# Making shortcut
if [ "$INSTALL_METHOD" != "STEAM" ]; then
        POL_Shortcut "SWTFU_Autorun.exe" "$TITLE" "Star Wars : The Force Unleashed - Ultimate Sith Edition.png" ""
fi
 
# Game protection warning
if [ "$INSTALL_METHOD" == "DVD" ]; then
        POL_SetupWindow_message "$(eval_gettext 'You must disable anti-piracy protections of this game\nif you want to play it with wine')" "$TITLE"
fi

POL_SetupWindow_message "$(eval_gettext '$TITLE has been successfully installed.')"
 
POL_SetupWindow_Close
exit 0
