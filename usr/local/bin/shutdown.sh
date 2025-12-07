#!/bin/bash

DEVICES=("/dev/input/js0" "/dev/input/js1")
IDLE_LIMIT=300  # 5 minutes in seconds
CHECK_INTERVAL=30
LAST_ACTIVITY_FILE="/tmp/last_input_activity"

# Initialize activity time
date +%s > "$LAST_ACTIVITY_FILE"

# Background checker
(
  echo "[$(date)] Waiting 5 minutes before starting idle checks..."
  sleep "$IDLE_LIMIT"
  # reset idle timer
  date +%s > "$LAST_ACTIVITY_FILE"

  while true; do
    sleep "$CHECK_INTERVAL"
    NOW=$(date +%s)
    LAST=$(cat "$LAST_ACTIVITY_FILE")
    IDLE_TIME=$((NOW - LAST))

    echo "[$(date)] Seconds since last activity: $IDLE_TIME"

    SSH_SESSIONS=$(who | grep -c 'pts/')
    if (( IDLE_TIME > IDLE_LIMIT )) && (( SSH_SESSIONS == 0 )); then
      echo "[$(date)] Idle limit exceeded and no SSH session detected. Initiating shutdown..."
      curl "http://192.168.1.199/cm?cmnd=Backlog%20Delay%20300%3B%20Power%200"
      sudo halt -p
      exit 0
    elif (( SSH_SESSIONS > 0 )); then
      echo "[$(date)] SSH session(s) detected – skipping shutdown for now."
    fi
  done
) &

# Function to monitor a single device
monitor_device() {
  local DEVICE=$1
  if [[ -e "$DEVICE" ]]; then
    jstest "$DEVICE" 2>&1 | stdbuf -oL tr '\r' '\n' | while read -r line; do
      if [[ "$line" == *on* || "$line" =~ [0-9]+:\ *-?[1-9][0-9]* ]]; then
        echo "[$(date)] Input activity detected on $DEVICE."
        # write atomically to prevent write locks
        printf "%s" "$(date +%s)" > "$LAST_ACTIVITY_FILE.tmp"
        mv -f "$LAST_ACTIVITY_FILE.tmp" "$LAST_ACTIVITY_FILE"
        #date +%s > "$LAST_ACTIVITY_FILE"
      fi
    done
  else
    echo "[$(date)] Device $DEVICE not found. Skipping."
  fi
}

# Launch a monitoring loop for each device
for dev in "${DEVICES[@]}"; do
  monitor_device "$dev" &
done

# Wait for background jobs (input monitors) to finish
wait
