#!/bin/bash
# Date : (2015-05-29 18:38)
# Date : (2015-05-29 22:01)
# Wine version used : 1.6.2-dos_support_0.6
# Distribution used to test : Ubuntu 14.04 Trusty x64 + Debian 7.0 Wheezy x64
# Author : med_freeman
# Licence : Retail
# Only For : http://www.playonlinux.com
 
[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"
 
TITLE="GOG.com - Megarace"
PREFIX="Megarace_gog"
GOGID="megarace"
EDITOR="Cryo Interactive / Anuman Interactive"
GAME_URL="http://www.gog.com/game/megarace_1_2"
AUTHOR="med_freeman"
WINE_VERSION="1.6.2-dos_support_0.6"
WINE_ARCH="x86"
 
POL_GetSetupImages "http://files.playonlinux.com/resources/setups/$PREFIX/top.jpg" "http://files.playonlinux.com/resources/setups/$PREFIX/left.jpg" "$TITLE"
POL_SetupWindow_Init
POL_SetupWindow_SetID 2539
 
POL_Debug_Init
 
POL_SetupWindow_presentation "$TITLE" "$EDITOR" "$GAME_URL" "$AUTHOR" "$PREFIX"
 
# Download / Select GOG setup
POL_Call POL_GoG_setup "$GOGID" "0b2010804bce973cf5c48a53df162282"
 
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
cpu_core=auto
cpu_cputype=auto
cpu_cycles=8000
mixer_rate=22050
mixer_blocksize=2048
mixer_prebuffer=80
sblaster_sbtype=sb16
sblaster_sbbase=220
sblaster_irq=5
sblaster_dma=1
sblaster_hdma=5
sblaster_mixer=true
sblaster_oplmode=auto
sblaster_oplrate=22050
_EOFCFG_

# mount iso as E drive
cat <<_EOFAE_ > "$WINEPREFIX/drive_c/autoexec.bat"
@ECHO OFF
imgmount E "C:\GOGGAM~1\Megarace\MEGARACE.DAT" -t iso
_EOFAE_
 
POL_Shortcut "RACEPRG.EXE" "Megarace" "Megarace.png" "ENG ADP220 SBP2225 JOY0000-0000-0000-0000 EMS 386" "Game;RacingGame;"
POL_Shortcut_Document "Megarace" "$GOGROOT/Megarace/manual.pdf"
 
POL_SetupWindow_Close
exit 0
