#!/bin/bash

ROM="$1"
REMOTE_PI="192.168.1.193"
PORT=5000
MAX_RETRIES=5
SLEEP_SECONDS=3

for i in $(seq 1 $MAX_RETRIES); do
    echo "Attempt $i: sending ROM info..."

    # Send the ROM and read one line of reply
    ACK=$(echo "$ROM" | nc -w 3 $REMOTE_PI $PORT)

    if [[ "$ACK" == "OK" ]]; then
        echo "Received ACK from remote Pi!"
        exit 0
    else
        echo "No ACK. Retrying in $SLEEP_SECONDS sec..."
        sleep $SLEEP_SECONDS
    fi
done

echo "Failed to send ROM after $MAX_RETRIES attempts."
exit 1
