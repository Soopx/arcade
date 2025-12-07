#!/bin/bash

export MAGICK_DISPLAY=""

DEFAULT_IMAGE="/home/admin/marquees/image.jpg"
TMP_IMAGE="/tmp/resized_marquee_boot.jpg"

echo "$(date) - Running show_default_image.sh" >> /home/admin/display_image_debug.log
echo "DEFAULT_IMAGE: $DEFAULT_IMAGE" >> /home/admin/display_image_debug.log
echo "File exists? $(ls -l $DEFAULT_IMAGE 2>&1)" >> /home/admin/display_image_debug.log

ORIG_WIDTH=$(identify -format "%w" "$DEFAULT_IMAGE")
ORIG_HEIGHT=$(identify -format "%h" "$DEFAULT_IMAGE")

NEW_HEIGHT=$(awk "BEGIN { printf \"%d\", $ORIG_HEIGHT * 2.339 }")

echo "Original size: ${ORIG_WIDTH}x${ORIG_HEIGHT}" >> /home/admin/display_image_debug.log
echo "New height: ${NEW_HEIGHT}" >> /home/admin/display_image_debug.log

# Stretch vertically by scaling height only
convert "$DEFAULT_IMAGE" -resize ${ORIG_WIDTH}x${NEW_HEIGHT}\! "$TMP_IMAGE"

# Kill any previous fbi instances
sudo killall fbi 2>/dev/null

# Display the stretched image
sudo fbi -T 1 -a -noverbose "$TMP_IMAGE" > /dev/null 2>&1 &
