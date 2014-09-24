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
        POL_Wine_OverrideDLL "" "dwrite" # Needed fix or we get invisible fonts in steam
        POL_Call POL_Install_steam
fi
POL_Call POL_Install_dxfullsetup
 
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

Set_Managed "Off"
POL_Wine_X11Drv "Decorated" "N"
POL_Wine_X11Drv "GrabFullscreen" "Y"
 
# Making shortcut
if [ "$INSTALL_METHOD" != "STEAM" ]; then
        POL_Shortcut "SWTFU_Autorun.exe" "$TITLE" "Star Wars : The Force Unleashed - Ultimate Sith Edition.png" ""
fi
 
## BEGIN Configurator
if [ ! -e "$POL_USER_ROOT/configurations/configurators/" ]; then
mkdir -p "$POL_USER_ROOT/configurations/configurators/"
fi
  
cat << EOF1 > "$POL_USER_ROOT/configurations/configurators/$TITLE"
#!/bin/bash
 
[ "\$PLAYONLINUX" = "" ] && exit 0
source "\$PLAYONLINUX/lib/sources"
  
TITLE="Star Wars : The Force Unleashed - Ultimate Sith Edition"
PREFIX="swtfu"
 
if [ "$POL_LANG" == "fr" ]; then
TITLE="Star Wars : Le Pouvoir de la Force - Ultimate Sith Edition"
fi
  
POL_SetupWindow_checkexist()
{       
        if [ ! -e "\$POL_USER_ROOT/wineprefix/\$1" ]; then
                if [ "\$POL_LANG" == "fr" ]; then
                        LNG_PREFIX_NOT_EXIST="Le jeu n'est pas installé."
                else
                        LNG_PREFIX_NOT_EXIST="Game is not installed."
                fi
                POL_SetupWindow_message "\$(eval_gettext 'Game is not installed.')" "\$TITLE"
                POL_SetupWindow_Close
                exit 0
        fi
}
  
POL_SetupWindow_Init
POL_SetupWindow_checkexist "\$PREFIX"
 
# Setting prefix path
POL_Wine_SelectPrefix "$PREFIX"
 
if [ "\$POL_LANG" == "fr" ]; then
LNG_SWTFU_WELCOME="Bienvenu dans l'outil de configuration de\n\$TITLE.\nCe configurateur se limite aux touches communes à tout les types de claviers."
LNG_SWTFU_WARNING="Vous devez executer le jeu au moins une fois avant d'utiliser ce configurateur\npour qu'il fonctionne."
LNG_SWTFU_MENU="Que voulez-vous faire ?"
DEFAULT_CONFIG="Configuration par defaut"
CUSTOM_CONFIG="Configurer le jeu"
LNG_SWTFU_RES="Choisissez la résolution de jeu qui vous conviens"
LNG_SWTFU_DETAIL="Selectionnez le niveau de détails"
LNG_DETAIL_LOW="Faible"
LNG_DETAIL_HIGH="Haut"
LNG_SWTFU_KEYBOARD="Selectionnez le périphérique d'entrée"
LNG_USE_KEYBOARD="Clavier"
LNG_USE_JOYPAD="Joypad"
LNG_UP="Haut"
LNG_DOWN="Bas"
LNG_LEFT="Gauche"
LNG_RIGHT="Droite"
LNG_LSHIFT="Maj Gauche"
LNG_RSHIFT="Maj Droite"
LNG_LCTRL="CTRL Gauche"
LNG_RCTRL="CTRL Droite"
LNG_LALT="ALT Gauche"
LNG_RALT="ALT Droite"
LNG_BACK="Retour"
LNG_RETURN="Entrer"
LNG_SPACE="Espace"
LNG_ESC="Echap"
LNG_B0="Clique Gauche"
LNG_B1="Clique Droit"
LNG_B2="Clique Milieu"
LNG_SWTFU_FORWARD="Sélectionnez la touche pour Avancer"
LNG_SWTFU_BACK="Sélectionnez la touche pour Reculer"
LNG_SWTFU_LEFT="Sélectionnez la touche pour Mouvement à Gauche"
LNG_SWTFU_RIGHT="Sélectionnez la touche pour Mouvement à Droite"
LNG_SWTFU_DASH="Sélectionnez la touche pour Charge de Force"
LNG_SWTFU_JUMP="Sélectionnez la touche pour Sauter"
LNG_SWTFU_PAUSE="Sélectionnez la touche pour Pause"
LNG_SWTFU_CENTER="Sélectionnez la touche pour Centrer caméra"
LNG_SWTFU_OPTIONS="Sélectionnez la touche pour Options"
LNG_SWTFU_ATTACK="Sélectionnez la touche pour Attaque au sabre laser"
LNG_SWTFU_BLOCK="Sélectionnez la touche pour Bloquer"
LNG_SWTFU_GRIP="Sélectionnez la touche pour Préhension de Force"
LNG_SWTFU_PUSH="Sélectionnez la touche pour Projection de Force"
LNG_SWTFU_LIGHT="Sélectionnez la touche pour Eclair de Force"
LNG_SWTFU_LOCK="Sélectionnez la touche pour Verrouillage cible"
LNG_SWTFU_CAMERA="Sélectionnez la touche pour Caméra de poursuite"
else
LNG_SWTFU_WELCOME="Welcome in\n\$TITLE configuration utils.\nThis configurator is limited only to common keys for all kinds of keyboards."
LNG_SWTFU_WARNING="You must launch the game at least once before using this configurator\nfor it to work."
LNG_SWTFU_MENU="What do you want to do ?"
DEFAULT_CONFIG="Default configuration"
CUSTOM_CONFIG="Configure this game"
LNG_SWTFU_RES="Choose the game resolution you want"
LNG_SWTFU_DETAIL="Select your details level"
LNG_DETAIL_LOW="Low"
LNG_DETAIL_HIGH="High"
LNG_SWTFU_KEYBOARD="Select your input peripherical"
LNG_USE_KEYBOARD="Keyboard"
LNG_USE_JOYPAD="Joypad"
LNG_UP="Up"
LNG_DOWN="Down"
LNG_LEFT="Left"
LNG_RIGHT="Right"
LNG_LSHIFT="Left Shift"
LNG_RSHIFT="Right Shift"
LNG_LCTRL="Left CTRL"
LNG_RCTRL="Right CTRL"
LNG_LALT="Left ALT"
LNG_RALT="Right ALT"
LNG_BACK="Backspace"
LNG_RETURN="Return"
LNG_SPACE="Space"
LNG_ESC="Escape"
LNG_B0="Left Click"
LNG_B1="Right Click"
LNG_B2="Middle Click"
LNG_SWTFU_FORWARD="Select key for Forward"
LNG_SWTFU_BACK="Select key for Back"
LNG_SWTFU_LEFT="Select key for Move to the left"
LNG_SWTFU_RIGHT="Select key for Move to the right"
LNG_SWTFU_DASH="Select key for Force Dash"
LNG_SWTFU_JUMP="Select key for Jump"
LNG_SWTFU_PAUSE="Select key for Pause"
LNG_SWTFU_CENTER="Select key for Center camera"
LNG_SWTFU_OPTIONS="Select key for Options"
LNG_SWTFU_ATTACK="Select key for Lightsaber attack"
LNG_SWTFU_BLOCK="Select key for BLock"
LNG_SWTFU_GRIP="Select key for Force grip"
LNG_SWTFU_PUSH="Select key for Force push"
LNG_SWTFU_LIGHT="Select key for Force lightning"
LNG_SWTFU_LOCK="Select key for Lock-on"
LNG_SWTFU_CAMERA="Select key for Action camera"
fi
 
POL_SetupWindow_message "\$LNG_SWTFU_WELCOME" "\$TITLE"
  
WINE_USER=\`id -un\`
cd "\$WINEPREFIX/drive_c/users/\$WINE_USER/Local Settings/Application Data/"
SWTFU_CONFIG=\`find . -name "Config.xml"\`
 
#Check if config file already exist
if [ "\$SWTFU_CONFIG" == "" ];then
        POL_SetupWindow_message "\$LNG_SWTFU_WARNING" "\$TITLE"
        POL_SetupWindow_Close
        exit 0
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_MENU" "\$TITLE" "\$DEFAULT_CONFIG-\$CUSTOM_CONFIG" "-" "\$DEFAULT_CONFIG"
SWTFU_DEFAULT="\$APP_ANSWER"
 
if [ "\$SWTFU_DEFAULT" == "\$DEFAULT_CONFIG" ];then
cat << EOF2 > "\$SWTFU_CONFIG"
<?xml version="1.0" encoding="utf-8" ?>
<r>
<s id="Version">1</s>
<s id="VideoWidth">800</s>
<s id="VideoHeight">600</s>
<s id="LowDetail">1</s>
<s id="IsKBAndMouse">TRUE</s>
<s id="MovementForward">DIK_W</s>
<s id="MovementLeft">DIK_A</s>
<s id="MovementBack">DIK_S</s>
<s id="MovementRight">DIK_D</s>
<s id="ForceDash">DIK_LSHIFT</s>
<s id="Jump">DIK_SPACE</s>
<s id="Pause">DIK_RETURN</s>
<s id="CenterCamera">DIK_C</s>
<s id="Options">DIK_ESCAPE</s>
<s id="LightSaberAttack">MOUSE_B0</s>
<s id="Block">DIK_R</s>
<s id="ForceGrip">MOUSE_B1</s>
<s id="ForcePush">DIK_E</s>
<s id="ForceLightning">DIK_Q</s>
<s id="LockOn">DIK_LCONTROL</s>
<s id="ActivateActionCamera">DIK_V</s>
<s id="IsMouseXAxisInverted">FALSE</s>
<s id="IsMouseYAxisInverted">FALSE</s>
<s id="ClothLevel">0</s>
</r>
EOF2
else
POL_SetupWindow_menu_list "\$LNG_SWTFU_RES" "\$TITLE" "800x600-1024x768-1152x854-1280x720-1280x768-1280x800-1280x960-1280x1024" "-" "800x600"
SELECTED_RES="\$APP_ANSWER"
  
if [ "\$SELECTED_RES" == "800x600" ];then
        ResX="800"
        ResY="600"
elif [ "\$SELECTED_RES" == "1024x768" ];then
        ResX="1024"
        ResY="768"
elif [ "\$SELECTED_RES" == "1152x854" ];then
        ResX="1152"
        ResY="854"
elif [ "\$SELECTED_RES" == "1280x720" ];then
        ResX="1280"
        ResY="720"
elif [ "\$SELECTED_RES" == "1280x768" ];then
        ResX="1280"
        ResY="768"
elif [ "\$SELECTED_RES" == "1280x800" ];then
        ResX="1280"
        ResY="800"
elif [ "\$SELECTED_RES" == "1280x960" ];then
        ResX="1280"
        ResY="960"
elif [ "\$SELECTED_RES" == "1280x1024" ];then
        ResX="1280"
        ResY="1024"
else
        ResX="800"
        ResY="600"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_DETAIL" "\$TITLE" "\$LNG_DETAIL_LOW-\$LNG_DETAIL_HIGH" "-" "\$LNG_DETAIL_LOW"
DETAIL_LEVEL="\$APP_ANSWER"
  
if [ "\$DETAIL_LEVEL" == "\$LNG_DETAIL_LOW" ];then
        DETAIL_LEVEL="1"
else
        DETAIL_LEVEL="0"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_KEYBOARD" "\$TITLE" "\$LNG_USE_KEYBOARD-\$LNG_USE_JOYPAD" "-" "\$LNG_USE_KEYBOARD"
USE_KEYBOARD="\$APP_ANSWER"
  
if [ "\$USE_KEYBOARD" == "\$LNG_USE_KEYBOARD" ];then
        USE_KEYBOARD="TRUE"
else
        USE_KEYBOARD="FALSE"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_FORWARD" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "W"
SWTFU_FORWARD="\$APP_ANSWER"
  
if [ "\$SWTFU_FORWARD" == "\$LNG_UP" ];then
        KEY_FORWARD="UP"
elif [ "\$SWTFU_FORWARD" == "\$LNG_DOWN" ];then
        KEY_FORWARD="DOWN"
elif [ "\$SWTFU_FORWARD" == "\$LNG_LEFT" ];then
        KEY_FORWARD="LEFT"
elif [ "\$SWTFU_FORWARD" == "\$LNG_RIGHT" ];then
        KEY_FORWARD="RIGHT"
elif [ "\$SWTFU_FORWARD" == "\$LNG_LSHIFT" ];then
        KEY_FORWARD="LSHIFT"
elif [ "\$SWTFU_FORWARD" == "\$LNG_RSHIFT" ];then
        KEY_FORWARD="RSHIFT"
elif [ "\$SWTFU_FORWARD" == "\$LNG_LCTRL" ];then
        KEY_FORWARD="LCONTROL"
elif [ "\$SWTFU_FORWARD" == "\$LNG_RCTRL" ];then
        KEY_FORWARD="RCONTROL"
elif [ "\$SWTFU_FORWARD" == "\$LNG_LALT" ];then
        KEY_FORWARD="LMENU"
elif [ "\$SWTFU_FORWARD" == "\$LNG_RALT" ];then
        KEY_FORWARD="RMENU"
elif [ "\$SWTFU_FORWARD" == "\$LNG_BACK" ];then
        KEY_FORWARD="BACK"
elif [ "\$SWTFU_FORWARD" == "\$LNG_RETURN" ];then
        KEY_FORWARD="RETURN"
elif [ "\$SWTFU_FORWARD" == "\$LNG_SPACE" ];then
        KEY_FORWARD="SPACE"
elif [ "\$SWTFU_FORWARD" == "\$LNG_ESC" ];then
        KEY_FORWARD="ESCAPE"
elif [ "\$SWTFU_FORWARD" == "\$LNG_B0" ];then
        KEY_FORWARD="MOUSE_B0"
elif [ "\$SWTFU_FORWARD" == "\$LNG_B1" ];then
        KEY_FORWARD="MOUSE_B1"
elif [ "\$SWTFU_FORWARD" == "\$LNG_B2" ];then
        KEY_FORWARD="MOUSE_B2"
else
        KEY_FORWARD="\$SWTFU_FORWARD"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_BACK" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "S"
SWTFU_BACK="\$APP_ANSWER"
  
if [ "\$SWTFU_BACK" == "\$LNG_UP" ];then
        KEY_BACK="UP"
elif [ "\$SWTFU_BACK" == "\$LNG_DOWN" ];then
        KEY_BACK="DOWN"
elif [ "\$SWTFU_BACK" == "\$LNG_LEFT" ];then
        KEY_BACK="LEFT"
elif [ "\$SWTFU_BACK" == "\$LNG_RIGHT" ];then
        KEY_BACK="RIGHT"
elif [ "\$SWTFU_BACK" == "\$LNG_LSHIFT" ];then
        KEY_BACK="LSHIFT"
elif [ "\$SWTFU_BACK" == "\$LNG_RSHIFT" ];then
        KEY_BACK="RSHIFT"
elif [ "\$SWTFU_BACK" == "\$LNG_LCTRL" ];then
        KEY_BACK="LCONTROL"
elif [ "\$SWTFU_BACK" == "\$LNG_RCTRL" ];then
        KEY_BACK="RCONTROL"
elif [ "\$SWTFU_BACK" == "\$LNG_LALT" ];then
        KEY_BACK="LMENU"
elif [ "\$SWTFU_BACK" == "\$LNG_RALT" ];then
        KEY_BACK="RMENU"
elif [ "\$SWTFU_BACK" == "\$LNG_BACK" ];then
        KEY_BACK="BACK"
elif [ "\$SWTFU_BACK" == "\$LNG_RETURN" ];then
        KEY_BACK="RETURN"
elif [ "\$SWTFU_BACK" == "\$LNG_SPACE" ];then
        KEY_BACK="SPACE"
elif [ "\$SWTFU_BACK" == "\$LNG_ESC" ];then
        KEY_BACK="ESCAPE"
elif [ "\$SWTFU_BACK" == "\$LNG_B0" ];then
        KEY_BACK="MOUSE_B0"
elif [ "\$SWTFU_BACK" == "\$LNG_B1" ];then
        KEY_BACK="MOUSE_B1"
elif [ "\$SWTFU_BACK" == "\$LNG_B2" ];then
        KEY_BACK="MOUSE_B2"
else
        KEY_BACK="\$SWTFU_BACK"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_LEFT" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "A"
SWTFU_LEFT="\$APP_ANSWER"
  
if [ "\$SWTFU_LEFT" == "\$LNG_UP" ];then
        KEY_LEFT="UP"
elif [ "\$SWTFU_LEFT" == "\$LNG_DOWN" ];then
        KEY_LEFT="DOWN"
elif [ "\$SWTFU_LEFT" == "\$LNG_LEFT" ];then
        KEY_LEFT="LEFT"
elif [ "\$SWTFU_LEFT" == "\$LNG_RIGHT" ];then
        KEY_LEFT="RIGHT"
elif [ "\$SWTFU_LEFT" == "\$LNG_LSHIFT" ];then
        KEY_LEFT="LSHIFT"
elif [ "\$SWTFU_LEFT" == "\$LNG_RSHIFT" ];then
        KEY_LEFT="RSHIFT"
elif [ "\$SWTFU_LEFT" == "\$LNG_LCTRL" ];then
        KEY_LEFT="LCONTROL"
elif [ "\$SWTFU_LEFT" == "\$LNG_RCTRL" ];then
        KEY_LEFT="RCONTROL"
elif [ "\$SWTFU_LEFT" == "\$LNG_LALT" ];then
        KEY_LEFT="LMENU"
elif [ "\$SWTFU_LEFT" == "\$LNG_RALT" ];then
        KEY_LEFT="RMENU"
elif [ "\$SWTFU_LEFT" == "\$LNG_LEFT" ];then
        KEY_LEFT="BACK"
elif [ "\$SWTFU_LEFT" == "\$LNG_RETURN" ];then
        KEY_LEFT="RETURN"
elif [ "\$SWTFU_LEFT" == "\$LNG_SPACE" ];then
        KEY_LEFT="SPACE"
elif [ "\$SWTFU_LEFT" == "\$LNG_ESC" ];then
        KEY_LEFT="ESCAPE"
elif [ "\$SWTFU_LEFT" == "\$LNG_B0" ];then
        KEY_LEFT="MOUSE_B0"
elif [ "\$SWTFU_LEFT" == "\$LNG_B1" ];then
        KEY_LEFT="MOUSE_B1"
elif [ "\$SWTFU_LEFT" == "\$LNG_B2" ];then
        KEY_LEFT="MOUSE_B2"
else
        KEY_LEFT="\$SWTFU_LEFT"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_RIGHT" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "D"
SWTFU_RIGHT="\$APP_ANSWER"
  
if [ "\$SWTFU_RIGHT" == "\$LNG_UP" ];then
        KEY_RIGHT="UP"
elif [ "\$SWTFU_RIGHT" == "\$LNG_DOWN" ];then
        KEY_RIGHT="DOWN"
elif [ "\$SWTFU_RIGHT" == "\$LNG_RIGHT" ];then
        KEY_RIGHT="LEFT"
elif [ "\$SWTFU_RIGHT" == "\$LNG_RIGHT" ];then
        KEY_RIGHT="RIGHT"
elif [ "\$SWTFU_RIGHT" == "\$LNG_LSHIFT" ];then
        KEY_RIGHT="LSHIFT"
elif [ "\$SWTFU_RIGHT" == "\$LNG_RSHIFT" ];then
        KEY_RIGHT="RSHIFT"
elif [ "\$SWTFU_RIGHT" == "\$LNG_LCTRL" ];then
        KEY_RIGHT="LCONTROL"
elif [ "\$SWTFU_RIGHT" == "\$LNG_RCTRL" ];then
        KEY_RIGHT="RCONTROL"
elif [ "\$SWTFU_RIGHT" == "\$LNG_LALT" ];then
        KEY_RIGHT="LMENU"
elif [ "\$SWTFU_RIGHT" == "\$LNG_RALT" ];then
        KEY_RIGHT="RMENU"
elif [ "\$SWTFU_RIGHT" == "\$LNG_RIGHT" ];then
        KEY_RIGHT="BACK"
elif [ "\$SWTFU_RIGHT" == "\$LNG_RETURN" ];then
        KEY_RIGHT="RETURN"
elif [ "\$SWTFU_RIGHT" == "\$LNG_SPACE" ];then
        KEY_RIGHT="SPACE"
elif [ "\$SWTFU_RIGHT" == "\$LNG_ESC" ];then
        KEY_RIGHT="ESCAPE"
elif [ "\$SWTFU_RIGHT" == "\$LNG_B0" ];then
        KEY_RIGHT="MOUSE_B0"
elif [ "\$SWTFU_RIGHT" == "\$LNG_B1" ];then
        KEY_RIGHT="MOUSE_B1"
elif [ "\$SWTFU_RIGHT" == "\$LNG_B2" ];then
        KEY_RIGHT="MOUSE_B2"
else
        KEY_RIGHT="\$SWTFU_RIGHT"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_DASH" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "\$LNG_LSHIFT"
SWTFU_DASH="\$APP_ANSWER"
  
if [ "\$SWTFU_DASH" == "\$LNG_UP" ];then
        KEY_DASH="UP"
elif [ "\$SWTFU_DASH" == "\$LNG_DOWN" ];then
        KEY_DASH="DOWN"
elif [ "\$SWTFU_DASH" == "\$LNG_DASH" ];then
        KEY_DASH="LEFT"
elif [ "\$SWTFU_DASH" == "\$LNG_DASH" ];then
        KEY_DASH="RIGHT"
elif [ "\$SWTFU_DASH" == "\$LNG_LSHIFT" ];then
        KEY_DASH="LSHIFT"
elif [ "\$SWTFU_DASH" == "\$LNG_RSHIFT" ];then
        KEY_DASH="RSHIFT"
elif [ "\$SWTFU_DASH" == "\$LNG_LCTRL" ];then
        KEY_DASH="LCONTROL"
elif [ "\$SWTFU_DASH" == "\$LNG_RCTRL" ];then
        KEY_DASH="RCONTROL"
elif [ "\$SWTFU_DASH" == "\$LNG_LALT" ];then
        KEY_DASH="LMENU"
elif [ "\$SWTFU_DASH" == "\$LNG_RALT" ];then
        KEY_DASH="RMENU"
elif [ "\$SWTFU_DASH" == "\$LNG_DASH" ];then
        KEY_DASH="BACK"
elif [ "\$SWTFU_DASH" == "\$LNG_RETURN" ];then
        KEY_DASH="RETURN"
elif [ "\$SWTFU_DASH" == "\$LNG_SPACE" ];then
        KEY_DASH="SPACE"
elif [ "\$SWTFU_DASH" == "\$LNG_ESC" ];then
        KEY_DASH="ESCAPE"
elif [ "\$SWTFU_DASH" == "\$LNG_B0" ];then
        KEY_DASH="MOUSE_B0"
elif [ "\$SWTFU_DASH" == "\$LNG_B1" ];then
        KEY_DASH="MOUSE_B1"
elif [ "\$SWTFU_DASH" == "\$LNG_B2" ];then
        KEY_DASH="MOUSE_B2"
else
        KEY_DASH="\$SWTFU_DASH"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_JUMP" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "\$LNG_SPACE"
SWTFU_JUMP="\$APP_ANSWER"
  
if [ "\$SWTFU_JUMP" == "\$LNG_UP" ];then
        KEY_JUMP="UP"
elif [ "\$SWTFU_JUMP" == "\$LNG_DOWN" ];then
        KEY_JUMP="DOWN"
elif [ "\$SWTFU_JUMP" == "\$LNG_JUMP" ];then
        KEY_JUMP="LEFT"
elif [ "\$SWTFU_JUMP" == "\$LNG_JUMP" ];then
        KEY_JUMP="RIGHT"
elif [ "\$SWTFU_JUMP" == "\$LNG_LSHIFT" ];then
        KEY_JUMP="LSHIFT"
elif [ "\$SWTFU_JUMP" == "\$LNG_RSHIFT" ];then
        KEY_JUMP="RSHIFT"
elif [ "\$SWTFU_JUMP" == "\$LNG_LCTRL" ];then
        KEY_JUMP="LCONTROL"
elif [ "\$SWTFU_JUMP" == "\$LNG_RCTRL" ];then
        KEY_JUMP="RCONTROL"
elif [ "\$SWTFU_JUMP" == "\$LNG_LALT" ];then
        KEY_JUMP="LMENU"
elif [ "\$SWTFU_JUMP" == "\$LNG_RALT" ];then
        KEY_JUMP="RMENU"
elif [ "\$SWTFU_JUMP" == "\$LNG_JUMP" ];then
        KEY_JUMP="BACK"
elif [ "\$SWTFU_JUMP" == "\$LNG_RETURN" ];then
        KEY_JUMP="RETURN"
elif [ "\$SWTFU_JUMP" == "\$LNG_SPACE" ];then
        KEY_JUMP="SPACE"
elif [ "\$SWTFU_JUMP" == "\$LNG_ESC" ];then
        KEY_JUMP="ESCAPE"
elif [ "\$SWTFU_JUMP" == "\$LNG_B0" ];then
        KEY_DASH="MOUSE_B0"
elif [ "\$SWTFU_JUMP" == "\$LNG_B1" ];then
        KEY_JUMP="MOUSE_B1"
elif [ "\$SWTFU_JUMP" == "\$LNG_B2" ];then
        KEY_JUMP="MOUSE_B2"
else
        KEY_JUMP="\$SWTFU_JUMP"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_PAUSE" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "\$LNG_RETURN"
SWTFU_PAUSE="\$APP_ANSWER"
  
if [ "\$SWTFU_PAUSE" == "\$LNG_UP" ];then
        KEY_PAUSE="UP"
elif [ "\$SWTFU_PAUSE" == "\$LNG_DOWN" ];then
        KEY_PAUSE="DOWN"
elif [ "\$SWTFU_PAUSE" == "\$LNG_PAUSE" ];then
        KEY_PAUSE="LEFT"
elif [ "\$SWTFU_PAUSE" == "\$LNG_PAUSE" ];then
        KEY_PAUSE="RIGHT"
elif [ "\$SWTFU_PAUSE" == "\$LNG_LSHIFT" ];then
        KEY_PAUSE="LSHIFT"
elif [ "\$SWTFU_PAUSE" == "\$LNG_RSHIFT" ];then
        KEY_PAUSE="RSHIFT"
elif [ "\$SWTFU_PAUSE" == "\$LNG_LCTRL" ];then
        KEY_PAUSE="LCONTROL"
elif [ "\$SWTFU_PAUSE" == "\$LNG_RCTRL" ];then
        KEY_PAUSE="RCONTROL"
elif [ "\$SWTFU_PAUSE" == "\$LNG_LALT" ];then
        KEY_PAUSE="LMENU"
elif [ "\$SWTFU_PAUSE" == "\$LNG_RALT" ];then
        KEY_PAUSE="RMENU"
elif [ "\$SWTFU_PAUSE" == "\$LNG_PAUSE" ];then
        KEY_PAUSE="BACK"
elif [ "\$SWTFU_PAUSE" == "\$LNG_RETURN" ];then
        KEY_PAUSE="RETURN"
elif [ "\$SWTFU_PAUSE" == "\$LNG_SPACE" ];then
        KEY_PAUSE="SPACE"
elif [ "\$SWTFU_PAUSE" == "\$LNG_ESC" ];then
        KEY_PAUSE="ESCAPE"
elif [ "\$SWTFU_PAUSE" == "\$LNG_B0" ];then
        KEY_PAUSE="MOUSE_B0"
elif [ "\$SWTFU_PAUSE" == "\$LNG_B1" ];then
        KEY_PAUSE="MOUSE_B1"
elif [ "\$SWTFU_PAUSE" == "\$LNG_B2" ];then
        KEY_PAUSE="MOUSE_B2"
else
        KEY_PAUSE="\$SWTFU_PAUSE"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_CENTER" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "C"
SWTFU_CENTER="\$APP_ANSWER"
 
if [ "\$SWTFU_CENTER" == "\$LNG_UP" ];then
        KEY_CENTER="UP"
elif [ "\$SWTFU_CENTER" == "\$LNG_DOWN" ];then
        KEY_CENTER="DOWN"
elif [ "\$SWTFU_CENTER" == "\$LNG_CENTER" ];then
        KEY_CENTER="LEFT"
elif [ "\$SWTFU_CENTER" == "\$LNG_CENTER" ];then
        KEY_CENTER="RIGHT"
elif [ "\$SWTFU_CENTER" == "\$LNG_LSHIFT" ];then
        KEY_CENTER="LSHIFT"
elif [ "\$SWTFU_CENTER" == "\$LNG_RSHIFT" ];then
        KEY_CENTER="RSHIFT"
elif [ "\$SWTFU_CENTER" == "\$LNG_LCTRL" ];then
        KEY_CENTER="LCONTROL"
elif [ "\$SWTFU_CENTER" == "\$LNG_RCTRL" ];then
        KEY_CENTER="RCONTROL"
elif [ "\$SWTFU_CENTER" == "\$LNG_LALT" ];then
        KEY_CENTER="LMENU"
elif [ "\$SWTFU_CENTER" == "\$LNG_RALT" ];then
        KEY_CENTER="RMENU"
elif [ "\$SWTFU_CENTER" == "\$LNG_CENTER" ];then
        KEY_CENTER="BACK"
elif [ "\$SWTFU_CENTER" == "\$LNG_RETURN" ];then
        KEY_CENTER="RETURN"
elif [ "\$SWTFU_CENTER" == "\$LNG_SPACE" ];then
        KEY_CENTER="SPACE"
elif [ "\$SWTFU_CENTER" == "\$LNG_ESC" ];then
        KEY_CENTER="ESCAPE"
elif [ "\$SWTFU_CENTER" == "\$LNG_B0" ];then
        KEY_CENTER="MOUSE_B0"
elif [ "\$SWTFU_CENTER" == "\$LNG_B1" ];then
        KEY_CENTER="MOUSE_B1"
elif [ "\$SWTFU_CENTER" == "\$LNG_B2" ];then
        KEY_CENTER="MOUSE_B2"
else
        KEY_CENTER="\$SWTFU_CENTER"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_OPTIONS" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "\$LNG_ESC"
SWTFU_OPTIONS="\$APP_ANSWER"
 
if [ "\$SWTFU_OPTIONS" == "\$LNG_UP" ];then
        KEY_OPTIONS="UP"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_DOWN" ];then
        KEY_OPTIONS="DOWN"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_OPTIONS" ];then
        KEY_OPTIONS="LEFT"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_OPTIONS" ];then
        KEY_OPTIONS="RIGHT"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_LSHIFT" ];then
        KEY_OPTIONS="LSHIFT"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_RSHIFT" ];then
        KEY_OPTIONS="RSHIFT"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_LCTRL" ];then
        KEY_OPTIONS="LCONTROL"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_RCTRL" ];then
        KEY_OPTIONS="RCONTROL"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_LALT" ];then
        KEY_OPTIONS="LMENU"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_RALT" ];then
        KEY_OPTIONS="RMENU"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_OPTIONS" ];then
        KEY_OPTIONS="BACK"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_RETURN" ];then
        KEY_OPTIONS="RETURN"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_SPACE" ];then
        KEY_OPTIONS="SPACE"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_ESC" ];then
        KEY_OPTIONS="ESCAPE"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_B0" ];then
        KEY_OPTIONS="MOUSE_B0"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_B1" ];then
        KEY_OPTIONS="MOUSE_B1"
elif [ "\$SWTFU_OPTIONS" == "\$LNG_B2" ];then
        KEY_OPTIONS="MOUSE_B2"
else
        KEY_OPTIONS="\$SWTFU_OPTIONS"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_ATTACK" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "\$LNG_B0"
SWTFU_ATTACK="\$APP_ANSWER"
 
if [ "\$SWTFU_ATTACK" == "\$LNG_UP" ];then
        KEY_ATTACK="UP"
elif [ "\$SWTFU_ATTACK" == "\$LNG_DOWN" ];then
        KEY_ATTACK="DOWN"
elif [ "\$SWTFU_ATTACK" == "\$LNG_ATTACK" ];then
        KEY_ATTACK="LEFT"
elif [ "\$SWTFU_ATTACK" == "\$LNG_ATTACK" ];then
        KEY_ATTACK="RIGHT"
elif [ "\$SWTFU_ATTACK" == "\$LNG_LSHIFT" ];then
        KEY_ATTACK="LSHIFT"
elif [ "\$SWTFU_ATTACK" == "\$LNG_RSHIFT" ];then
        KEY_ATTACK="RSHIFT"
elif [ "\$SWTFU_ATTACK" == "\$LNG_LCTRL" ];then
        KEY_ATTACK="LCONTROL"
elif [ "\$SWTFU_ATTACK" == "\$LNG_RCTRL" ];then
        KEY_ATTACK="RCONTROL"
elif [ "\$SWTFU_ATTACK" == "\$LNG_LALT" ];then
        KEY_ATTACK="LMENU"
elif [ "\$SWTFU_ATTACK" == "\$LNG_RALT" ];then
        KEY_ATTACK="RMENU"
elif [ "\$SWTFU_ATTACK" == "\$LNG_ATTACK" ];then
        KEY_ATTACK="BACK"
elif [ "\$SWTFU_ATTACK" == "\$LNG_RETURN" ];then
        KEY_ATTACK="RETURN"
elif [ "\$SWTFU_ATTACK" == "\$LNG_SPACE" ];then
        KEY_ATTACK="SPACE"
elif [ "\$SWTFU_ATTACK" == "\$LNG_ESC" ];then
        KEY_ATTACK="ESCAPE"
elif [ "\$SWTFU_ATTACK" == "\$LNG_B0" ];then
        KEY_ATTACK="MOUSE_B0"
elif [ "\$SWTFU_ATTACK" == "\$LNG_B1" ];then
        KEY_ATTACK="MOUSE_B1"
elif [ "\$SWTFU_ATTACK" == "\$LNG_B2" ];then
        KEY_ATTACK="MOUSE_B2"
else
        KEY_ATTACK="\$SWTFU_ATTACK"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_BLOCK" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "R"
SWTFU_BLOCK="\$APP_ANSWER"
 
if [ "\$SWTFU_BLOCK" == "\$LNG_UP" ];then
        KEY_BLOCK="UP"
elif [ "\$SWTFU_BLOCK" == "\$LNG_DOWN" ];then
        KEY_BLOCK="DOWN"
elif [ "\$SWTFU_BLOCK" == "\$LNG_BLOCK" ];then
        KEY_BLOCK="LEFT"
elif [ "\$SWTFU_BLOCK" == "\$LNG_BLOCK" ];then
        KEY_BLOCK="RIGHT"
elif [ "\$SWTFU_BLOCK" == "\$LNG_LSHIFT" ];then
        KEY_BLOCK="LSHIFT"
elif [ "\$SWTFU_BLOCK" == "\$LNG_RSHIFT" ];then
        KEY_BLOCK="RSHIFT"
elif [ "\$SWTFU_BLOCK" == "\$LNG_LCTRL" ];then
        KEY_BLOCK="LCONTROL"
elif [ "\$SWTFU_BLOCK" == "\$LNG_RCTRL" ];then
        KEY_BLOCK="RCONTROL"
elif [ "\$SWTFU_BLOCK" == "\$LNG_LALT" ];then
        KEY_BLOCK="LMENU"
elif [ "\$SWTFU_BLOCK" == "\$LNG_RALT" ];then
        KEY_BLOCK="RMENU"
elif [ "\$SWTFU_BLOCK" == "\$LNG_BLOCK" ];then
        KEY_BLOCK="BACK"
elif [ "\$SWTFU_BLOCK" == "\$LNG_RETURN" ];then
        KEY_BLOCK="RETURN"
elif [ "\$SWTFU_BLOCK" == "\$LNG_SPACE" ];then
        KEY_BLOCK="SPACE"
elif [ "\$SWTFU_BLOCK" == "\$LNG_ESC" ];then
        KEY_BLOCK="ESCAPE"
elif [ "\$SWTFU_BLOCK" == "\$LNG_B0" ];then
        KEY_BLOCK="MOUSE_B0"
elif [ "\$SWTFU_BLOCK" == "\$LNG_B1" ];then
        KEY_BLOCK="MOUSE_B1"
elif [ "\$SWTFU_BLOCK" == "\$LNG_B2" ];then
        KEY_BLOCK="MOUSE_B2"
else
        KEY_BLOCK="\$SWTFU_BLOCK"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_GRIP" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "\$LNG_B1"
SWTFU_GRIP="\$APP_ANSWER"
 
if [ "\$SWTFU_GRIP" == "\$LNG_UP" ];then
        KEY_GRIP="UP"
elif [ "\$SWTFU_GRIP" == "\$LNG_DOWN" ];then
        KEY_GRIP="DOWN"
elif [ "\$SWTFU_GRIP" == "\$LNG_GRIP" ];then
        KEY_GRIP="LEFT"
elif [ "\$SWTFU_GRIP" == "\$LNG_GRIP" ];then
        KEY_GRIP="RIGHT"
elif [ "\$SWTFU_GRIP" == "\$LNG_LSHIFT" ];then
        KEY_GRIP="LSHIFT"
elif [ "\$SWTFU_GRIP" == "\$LNG_RSHIFT" ];then
        KEY_GRIP="RSHIFT"
elif [ "\$SWTFU_GRIP" == "\$LNG_LCTRL" ];then
        KEY_GRIP="LCONTROL"
elif [ "\$SWTFU_GRIP" == "\$LNG_RCTRL" ];then
        KEY_GRIP="RCONTROL"
elif [ "\$SWTFU_GRIP" == "\$LNG_LALT" ];then
        KEY_GRIP="LMENU"
elif [ "\$SWTFU_GRIP" == "\$LNG_RALT" ];then
        KEY_GRIP="RMENU"
elif [ "\$SWTFU_GRIP" == "\$LNG_GRIP" ];then
        KEY_GRIP="BACK"
elif [ "\$SWTFU_GRIP" == "\$LNG_RETURN" ];then
        KEY_GRIP="RETURN"
elif [ "\$SWTFU_GRIP" == "\$LNG_SPACE" ];then
        KEY_GRIP="SPACE"
elif [ "\$SWTFU_GRIP" == "\$LNG_ESC" ];then
        KEY_GRIP="ESCAPE"
elif [ "\$SWTFU_GRIP" == "\$LNG_B0" ];then
        KEY_GRIP="MOUSE_B0"
elif [ "\$SWTFU_GRIP" == "\$LNG_B1" ];then
        KEY_GRIP="MOUSE_B1"
elif [ "\$SWTFU_GRIP" == "\$LNG_B2" ];then
        KEY_GRIP="MOUSE_B2"
else
        KEY_GRIP="\$SWTFU_GRIP"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_PUSH" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "E"
SWTFU_PUSH="\$APP_ANSWER"
 
if [ "\$SWTFU_PUSH" == "\$LNG_UP" ];then
        KEY_PUSH="UP"
elif [ "\$SWTFU_PUSH" == "\$LNG_DOWN" ];then
        KEY_PUSH="DOWN"
elif [ "\$SWTFU_PUSH" == "\$LNG_PUSH" ];then
        KEY_PUSH="LEFT"
elif [ "\$SWTFU_PUSH" == "\$LNG_PUSH" ];then
        KEY_PUSH="RIGHT"
elif [ "\$SWTFU_PUSH" == "\$LNG_LSHIFT" ];then
        KEY_PUSH="LSHIFT"
elif [ "\$SWTFU_PUSH" == "\$LNG_RSHIFT" ];then
        KEY_PUSH="RSHIFT"
elif [ "\$SWTFU_PUSH" == "\$LNG_LCTRL" ];then
        KEY_PUSH="LCONTROL"
elif [ "\$SWTFU_PUSH" == "\$LNG_RCTRL" ];then
        KEY_PUSH="RCONTROL"
elif [ "\$SWTFU_PUSH" == "\$LNG_LALT" ];then
        KEY_PUSH="LMENU"
elif [ "\$SWTFU_PUSH" == "\$LNG_RALT" ];then
        KEY_PUSH="RMENU"
elif [ "\$SWTFU_PUSH" == "\$LNG_PUSH" ];then
        KEY_PUSH="BACK"
elif [ "\$SWTFU_PUSH" == "\$LNG_RETURN" ];then
        KEY_PUSH="RETURN"
elif [ "\$SWTFU_PUSH" == "\$LNG_SPACE" ];then
        KEY_PUSH="SPACE"
elif [ "\$SWTFU_PUSH" == "\$LNG_ESC" ];then
        KEY_PUSH="ESCAPE"
elif [ "\$SWTFU_PUSH" == "\$LNG_B0" ];then
        KEY_PUSH="MOUSE_B0"
elif [ "\$SWTFU_PUSH" == "\$LNG_B1" ];then
        KEY_PUSH="MOUSE_B1"
elif [ "\$SWTFU_PUSH" == "\$LNG_B2" ];then
        KEY_PUSH="MOUSE_B2"
else
        KEY_PUSH="\$SWTFU_PUSH"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_LIGHT" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "Q"
SWTFU_LIGHT="\$APP_ANSWER"
 
if [ "\$SWTFU_LIGHT" == "\$LNG_UP" ];then
        KEY_LIGHT="UP"
elif [ "\$SWTFU_LIGHT" == "\$LNG_DOWN" ];then
        KEY_LIGHT="DOWN"
elif [ "\$SWTFU_LIGHT" == "\$LNG_LIGHT" ];then
        KEY_LIGHT="LEFT"
elif [ "\$SWTFU_LIGHT" == "\$LNG_LIGHT" ];then
        KEY_LIGHT="RIGHT"
elif [ "\$SWTFU_LIGHT" == "\$LNG_LSHIFT" ];then
        KEY_LIGHT="LSHIFT"
elif [ "\$SWTFU_LIGHT" == "\$LNG_RSHIFT" ];then
        KEY_LIGHT="RSHIFT"
elif [ "\$SWTFU_LIGHT" == "\$LNG_LCTRL" ];then
        KEY_LIGHT="LCONTROL"
elif [ "\$SWTFU_LIGHT" == "\$LNG_RCTRL" ];then
        KEY_LIGHT="RCONTROL"
elif [ "\$SWTFU_LIGHT" == "\$LNG_LALT" ];then
        KEY_LIGHT="LMENU"
elif [ "\$SWTFU_LIGHT" == "\$LNG_RALT" ];then
        KEY_LIGHT="RMENU"
elif [ "\$SWTFU_LIGHT" == "\$LNG_LIGHT" ];then
        KEY_LIGHT="BACK"
elif [ "\$SWTFU_LIGHT" == "\$LNG_RETURN" ];then
        KEY_LIGHT="RETURN"
elif [ "\$SWTFU_LIGHT" == "\$LNG_SPACE" ];then
        KEY_LIGHT="SPACE"
elif [ "\$SWTFU_LIGHT" == "\$LNG_ESC" ];then
        KEY_LIGHT="ESCAPE"
elif [ "\$SWTFU_LIGHT" == "\$LNG_B0" ];then
        KEY_LIGHT="MOUSE_B0"
elif [ "\$SWTFU_LIGHT" == "\$LNG_B1" ];then
        KEY_LIGHT="MOUSE_B1"
elif [ "\$SWTFU_LIGHT" == "\$LNG_B2" ];then
        KEY_LIGHT="MOUSE_B2"
else
        KEY_LIGHT="\$SWTFU_LIGHT"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_LOCK" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "\$LNG_LCTRL"
SWTFU_LOCK="\$APP_ANSWER"
 
if [ "\$SWTFU_LOCK" == "\$LNG_UP" ];then
        KEY_LOCK="UP"
elif [ "\$SWTFU_LOCK" == "\$LNG_DOWN" ];then
        KEY_LOCK="DOWN"
elif [ "\$SWTFU_LOCK" == "\$LNG_LOCK" ];then
        KEY_LOCK="LEFT"
elif [ "\$SWTFU_LOCK" == "\$LNG_LOCK" ];then
        KEY_LOCK="RIGHT"
elif [ "\$SWTFU_LOCK" == "\$LNG_LSHIFT" ];then
        KEY_LOCK="LSHIFT"
elif [ "\$SWTFU_LOCK" == "\$LNG_RSHIFT" ];then
        KEY_LOCK="RSHIFT"
elif [ "\$SWTFU_LOCK" == "\$LNG_LCTRL" ];then
        KEY_LOCK="LCONTROL"
elif [ "\$SWTFU_LOCK" == "\$LNG_RCTRL" ];then
        KEY_LOCK="RCONTROL"
elif [ "\$SWTFU_LOCK" == "\$LNG_LALT" ];then
        KEY_LOCK="LMENU"
elif [ "\$SWTFU_LOCK" == "\$LNG_RALT" ];then
        KEY_LOCK="RMENU"
elif [ "\$SWTFU_LOCK" == "\$LNG_LOCK" ];then
        KEY_LOCK="BACK"
elif [ "\$SWTFU_LOCK" == "\$LNG_RETURN" ];then
        KEY_LOCK="RETURN"
elif [ "\$SWTFU_LOCK" == "\$LNG_SPACE" ];then
        KEY_LOCK="SPACE"
elif [ "\$SWTFU_LOCK" == "\$LNG_ESC" ];then
        KEY_LOCK="ESCAPE"
elif [ "\$SWTFU_LOCK" == "\$LNG_B0" ];then
        KEY_LOCK="MOUSE_B0"
elif [ "\$SWTFU_LOCK" == "\$LNG_B1" ];then
        KEY_LOCK="MOUSE_B1"
elif [ "\$SWTFU_LOCK" == "\$LNG_B2" ];then
        KEY_LOCK="MOUSE_B2"
else
        KEY_LOCK="\$SWTFU_LOCK"
fi
 
POL_SetupWindow_menu_list "\$LNG_SWTFU_CAMERA" "\$TITLE" "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-R-U-V-W-X-Y-Z-0-1-2-3-4-5-6-7-8-9-\$LNG_UP-\$LNG_DOWN-\$LNG_LEFT-\$LNG_RIGHT-\$LNG_LSHIFT-\$LNG_RSHIFT-\$LNG_LCTRL-\$LNG_RCTRL-\$LNG_LALT-\$LNG_RALT-\$LNG_BACK-\$LNG_RETURN-\$LNG_SPACE-\$LNG_ESC-\$LNG_B0-\$LNG_B1-\$LNG_B2" "-" "V"
SWTFU_CAMERA="\$APP_ANSWER"
 
if [ "\$SWTFU_CAMERA" == "\$LNG_UP" ];then
        KEY_CAMERA="UP"
elif [ "\$SWTFU_CAMERA" == "\$LNG_DOWN" ];then
        KEY_CAMERA="DOWN"
elif [ "\$SWTFU_CAMERA" == "\$LNG_CAMERA" ];then
        KEY_CAMERA="LEFT"
elif [ "\$SWTFU_CAMERA" == "\$LNG_CAMERA" ];then
        KEY_CAMERA="RIGHT"
elif [ "\$SWTFU_CAMERA" == "\$LNG_LSHIFT" ];then
        KEY_CAMERA="LSHIFT"
elif [ "\$SWTFU_CAMERA" == "\$LNG_RSHIFT" ];then
        KEY_CAMERA="RSHIFT"
elif [ "\$SWTFU_CAMERA" == "\$LNG_LCTRL" ];then
        KEY_CAMERA="LCONTROL"
elif [ "\$SWTFU_CAMERA" == "\$LNG_RCTRL" ];then
        KEY_CAMERA="RCONTROL"
elif [ "\$SWTFU_CAMERA" == "\$LNG_LALT" ];then
        KEY_CAMERA="LMENU"
elif [ "\$SWTFU_CAMERA" == "\$LNG_RALT" ];then
        KEY_CAMERA="RMENU"
elif [ "\$SWTFU_CAMERA" == "\$LNG_CAMERA" ];then
        KEY_CAMERA="BACK"
elif [ "\$SWTFU_CAMERA" == "\$LNG_RETURN" ];then
        KEY_CAMERA="RETURN"
elif [ "\$SWTFU_CAMERA" == "\$LNG_SPACE" ];then
        KEY_CAMERA="SPACE"
elif [ "\$SWTFU_CAMERA" == "\$LNG_ESC" ];then
        KEY_CAMERA="ESCAPE"
elif [ "\$SWTFU_CAMERA" == "\$LNG_B0" ];then
        KEY_CAMERA="MOUSE_B0"
elif [ "\$SWTFU_CAMERA" == "\$LNG_B1" ];then
        KEY_CAMERA="MOUSE_B1"
elif [ "\$SWTFU_CAMERA" == "\$LNG_B2" ];then
        KEY_CAMERA="MOUSE_B2"
else
        KEY_CAMERA="\$SWTFU_CAMERA"
fi
 
cat << EOF2 > "\$SWTFU_CONFIG"
<?xml version="1.0" encoding="utf-8" ?>
<r>
<s id="Version">1</s>
<s id="VideoWidth">\$ResX</s>
<s id="VideoHeight">\$ResY</s>
<s id="LowDetail">\$DETAIL_LEVEL</s>
<s id="IsKBAndMouse">\$USE_KEYBOARD</s>
<s id="MovementForward">DIK_\$KEY_FORWARD</s>
<s id="MovementLeft">DIK_\$KEY_LEFT</s>
<s id="MovementBack">DIK_\$KEY_BACK</s>
<s id="MovementRight">DIK_\$KEY_RIGHT</s>
<s id="ForceDash">DIK_\$KEY_DASH</s>
<s id="Jump">DIK_\$KEY_JUMP</s>
<s id="Pause">DIK_\$KEY_PAUSE</s>
<s id="CenterCamera">DIK_\$KEY_CENTER</s>
<s id="Options">DIK_\$KEY_OPTIONS</s>
<s id="LightSaberAttack">DIK_\$KEY_ATTACK</s>
<s id="Block">DIK_\$KEY_BLOCK</s>
<s id="ForceGrip">DIK_\$KEY_GRIP</s>
<s id="ForcePush">DIK_\$KEY_PUSH</s>
<s id="ForceLightning">DIK_\$KEY_LIGHT</s>
<s id="LockOn">DIK_\$KEY_LOCK</s>
<s id="ActivateActionCamera">DIK_\$KEY_CAMERA</s>
<s id="IsMouseXAxisInverted">FALSE</s>
<s id="IsMouseYAxisInverted">FALSE</s>
<s id="ClothLevel">0</s>
</r>
EOF2
 
# Fix mouse key
cp "\$SWTFU_CONFIG" "\$SWTFU_CONFIG.clean"
cat "\$SWTFU_CONFIG.clean" | sed -e 's/DIK_MOUSE_B/MOUSE_B/g' > "\$SWTFU_CONFIG"
rm "\$SWTFU_CONFIG.clean"
fi
  
POL_SetupWindow_Close
EOF1
## End Configurator
 
# Game protection warning
if [ "$INSTALL_METHOD" == "DVD" ]; then
        POL_SetupWindow_message "$(eval_gettext 'You must disable anti-piracy protections of this game\nif you want to play it with wine')" "$TITLE"
fi
 
POL_SetupWindow_Close
exit 0
