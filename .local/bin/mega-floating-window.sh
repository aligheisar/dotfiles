#!/bin/bash

# Get display width dynamically
WIDTH=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .current_mode.width')

# Define MEGA window width
MEGA_WIDTH=400

# Calculate X position
X_POS=$((WIDTH - MEGA_WIDTH - 8))

# Move both window titles
swaymsg "[title=\"MEGAsync\"] move position ${X_POS} 0"
swaymsg "[title=\"MEGA\"] move position ${X_POS} 0"
