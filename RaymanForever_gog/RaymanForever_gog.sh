#!/bin/bash
# Date : (2014-10-05 19:57)
# Date : (2014-10-07 16:28)
# Wine version used : 1.6.2-dos_support_0.6
# Distribution used to test : Ubuntu 14.04 Trusty x64 + Debian 7.0 Wheezy x64
# Author : med_freeman
# Licence : Retail
# Only For : http://www.playonlinux.com
 
[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"
 
TITLE="GOG.com - Rayman Forever"
PREFIX="RaymanForever_gog"
GOGID="rayman_forever"
EDITOR="Ubisoft"
GAME_URL="http://rayman.ubi.com/legends/"
AUTHOR="med_freeman"
WINE_VERSION="1.6.2-dos_support_0.6"
WINE_ARCH="x86"
 
POL_GetSetupImages "http://files.playonlinux.com/resources/setups/$PREFIX/top.jpg" "http://files.playonlinux.com/resources/setups/$PREFIX/left.jpg" "$TITLE"
POL_SetupWindow_Init
POL_SetupWindow_SetID 2293
 
POL_Debug_Init
 
POL_SetupWindow_presentation "$TITLE" "$EDITOR" "$GAME_URL" "$AUTHOR" "$PREFIX"
 
# Download / Select GOG setup
POL_Call POL_GoG_setup "$GOGID" "96e71ea03261646f7f5ce4cb27d6a222"
 
POL_System_SetArch "$WINE_ARCH"
POL_Wine_SelectPrefix "$PREFIX"
POL_Wine_PrefixCreate "$WINE_VERSION"
 
# Install GOG setup
POL_Call POL_GoG_install
 
cat <<_EOFCFG_ >> "$WINEPREFIX/playonlinux_dos.cfg"
manual_mount=true
dosbox_machine=svga_s3
dosbox_captures=capture
dosbox_memsize=16
cpu_core=simple
cpu_cputype=pentium_slow
cpu_cycles=15000
mixer_rate=22050
mixer_blocksize=2048
mixer_prebuffer=80
sblaster_sbtype=sb16
sblaster_sbbase=220
sblaster_irq=7
sblaster_dma=1
sblaster_hdma=5
sblaster_mixer=true
sblaster_oplmode=auto
sblaster_oplrate=22050
_EOFCFG_
 
# cd to game folder
cd "$GOGROOT/Rayman Forever"
# we need this to have the in-game music
# symlink ogg files down one folder, or mscdex doesn't recognize it
ln -s Music/*.ogg .
# edit game.inst to remove ogg paths, save to cue extension or mscdex doesn't recognize it
sed -e 's/Music\\//g' game.inst > game.cue
 
# use dos long dir aliases, fix for mscdex path too long, we need this to have the in-game music
cat <<_EOFAE_ > "$WINEPREFIX/drive_c/autoexec.bat"
imgmount E "C:\GOGGAM~1\RAYMAN~1\game.cue" -t cdrom
_EOFAE_
 
# Different games in the installer
RAYMAN="Rayman"
RAYMAN_DE="Rayman Designer"
RAYMAN_DE_MAPPER="Rayman Designer Mapper"
RAYMAN_FANS="Rayman by His Fans"
 
# Rayman
POL_Shortcut "RAYMAN.EXE" "$RAYMAN" "$RAYMAN.png" "" "Game;PlatformGame;"
# Rayman Designer
POL_Shortcut "RAYKIT.EXE" "$RAYMAN_DE" "$RAYMAN_DE.png" "ver=usa" "Game;PlatformGame;"
# Rayman Designer Mapper
POL_Shortcut "MAPPER.EXE" "$RAYMAN_DE_MAPPER" "" "ver=usa" "Game;PlatformGame;"
# Rayman by His Fans
POL_Shortcut "RAYFAN.EXE" "$RAYMAN_FANS" "$RAYMAN_FANS.png" "ver=usa" "Game;PlatformGame;"
# Manual
POL_Shortcut_Document "$RAYMAN" "$GOGROOT/Rayman Forever/Manual.pdf"
POL_Shortcut_Document "$RAYMAN_DE" "$GOGROOT/Rayman Forever/Manual.pdf"
POL_Shortcut_Document "$RAYMAN_DE_MAPPER" "$GOGROOT/Rayman Forever/Manual.pdf"
POL_Shortcut_Document "$RAYMAN_FANS" "$GOGROOT/Rayman Forever/Manual.pdf"
 
POL_SetupWindow_Close
exit 0
