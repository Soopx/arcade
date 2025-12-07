#!/bin/bash

echo "$(date) - DISPLAY SCRIPT STARTED with ROM='$1'" >> /home/admin/trace.log

# create a lock file for the default display script
touch /tmp/marquee_displayed.lock

ROM="$1"

# Extract basename (remove path)
ROM=$(basename "$ROM")

# Remove extension
BASENAME="${ROM%.*}"

MARQUEE_DIR="/home/admin/marquees"
DEFAULT_IMAGE="$MARQUEE_DIR/image.png"

EXTENSIONS=("png" "jpg" "jpeg")

FOUND_IMAGE=""

# Search for a matching image
for ext in "${EXTENSIONS[@]}"; do
    IMAGE="$MARQUEE_DIR/$BASENAME.$ext"
    if [[ -f "$IMAGE" ]]; then
        FOUND_IMAGE="$IMAGE"
        break
    fi
done

# If no match found, use default
if [[ -z "$FOUND_IMAGE" ]]; then
    FOUND_IMAGE="$DEFAULT_IMAGE"
    echo "$(date) - No specific marquee found for $ROM. Using default." >> /home/admin/display_image_debug.log
else
    echo "$(date) - Displaying marquee: $FOUND_IMAGE" >> /home/admin/display_image_debug.log
fi

# Get original dimensions
ORIG_WIDTH=$(identify -format "%w" "$FOUND_IMAGE")
ORIG_HEIGHT=$(identify -format "%h" "$FOUND_IMAGE")

# Calculate new height
NEW_HEIGHT=$(awk "BEGIN { printf \"%d\", $ORIG_HEIGHT * 2.29885 }")

# Prepare a temporary resized copy
TMP_IMAGE="/tmp/resized_marquee.png"

# Resize image, forcing aspect ratio
convert "$FOUND_IMAGE" -resize ${ORIG_WIDTH}x${NEW_HEIGHT}\! "$TMP_IMAGE"

# Kill any previous fbi instances
killall fbi 2>/dev/null

# Optional: clear console
clear

# Switch to tty1 so fbi has control
chvt 1
sleep 0.1

# Display the resized image
echo "$(date) - ABOUT TO RUN FBI" >> /home/admin/trace.log
fbi -T 1 -a -noverbose "$TMP_IMAGE" > /home/admin/fbi_debug.log 2>&1 &
echo "$(date) - FBI COMMAND RETURNED" >> /home/admin/trace.log
