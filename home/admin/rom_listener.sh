#!/bin/bash

PORT=5000
LOG=/home/admin/rom_listener.log



#display the default image first:
/usr/local/bin/show_default_image.sh

while true; do
    nc -lk -p $PORT -e /home/admin/handle_rom.sh
done
