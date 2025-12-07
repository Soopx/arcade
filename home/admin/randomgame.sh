#!/bin/bash

# Set your ROM directory
ROM_DIR="/home/admin/ROMs"

# Pick a random file from the ROM directory
ROM=$(find "$ROM_DIR" -type f | shuf -n 1)

LOGFILE="/tmp/ra.log"

# Launch RetroArch with the chosen ROM and core
/opt/retropie/emulators/retroarch/bin/retroarch-wrapped --log-file "$LOGFILE" --verbose -L /opt/retropie/libretrocores/lr-fbneo/fbneo_libretro.so "$ROM"

# Generate override after game exits
/home/admin/fbneo.cfg.sh "$ROM" "$LOGFILE"
