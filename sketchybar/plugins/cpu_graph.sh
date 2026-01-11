#!/bin/bash

STATE_FILE="/tmp/sketchybar_cpu_history"
MAX_POINTS=20

# Unicode graph levels (8-step)
LEVELS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

# Get total CPU usage
CPU=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')
CORES=$(sysctl -n hw.ncpu)
CPU=$(awk "BEGIN { printf \"%d\", $CPU / $CORES }")

(( CPU < 0 )) && CPU=0
(( CPU > 100 )) && CPU=100

# Map 0–100 → 0–7
LEVEL=$(( CPU * 7 / 100 ))

# Load history
if [[ -f "$STATE_FILE" ]]; then
  HISTORY=($(cat "$STATE_FILE"))
else
  HISTORY=()
fi

# Append new value
HISTORY+=($LEVEL)

# Trim history
if (( ${#HISTORY[@]} > MAX_POINTS )); then
  HISTORY=("${HISTORY[@]: -$MAX_POINTS}")
fi

# Save history
printf "%s " "${HISTORY[@]}" > "$STATE_FILE"

# Build graph
GRAPH=""
for v in "${HISTORY[@]}"; do
  GRAPH+="${LEVELS[$v]}"
done

# Color by last CPU value
if (( CPU < 40 )); then
  COLOR=0xff96D4C6
elif (( CPU < 70 )); then
  COLOR=0xffE6CA95
else
  COLOR=0xfff38ba8
fi

sketchybar --set cpu label="$GRAPH" label.color=$COLOR
