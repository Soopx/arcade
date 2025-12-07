#!/bin/bash

# Wait a few seconds to make sure NAS is mounted
sleep 10

# Source folders
ROM_SOURCE="/mnt/nas/Selected ROMs/Arcade"
MARQUEE_SOURCE="/mnt/nas/Marquees"

# Destination folders
ROM_DEST="/home/admin/ROMs"
MARQUEE_DEST="/home/admin/Marquees"

# Ensure local dirs exist
mkdir -p "$ROM_DEST"
mkdir -p "$MARQUEE_DEST"

# Rsync in background (non-blocking, skip files that haven't changed)
rsync -a --delete "$ROM_SOURCE/" "$ROM_DEST/"
rsync -a --delete "$MARQUEE_SOURCE/" "$MARQUEE_DEST/"
