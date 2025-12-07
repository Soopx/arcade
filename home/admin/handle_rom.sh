#!/bin/bash
read ROM
echo "$(date +"%F %T") - Received ROM: $ROM" >> /home/admin/rom_listener.log
/home/admin/display_image.sh "$ROM"
echo OK
