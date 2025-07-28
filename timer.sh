#!/bin/bash

# Simple timer replacement script
# Usage: timer 25m or timer 1500s or timer 25:00

# Function to parse time input
parse_time() {
    local input="$1"
    local total_seconds=0
    
    # Handle different formats
    if [[ $input =~ ^([0-9]+):([0-9]+)$ ]]; then
        # Format: MM:SS or HH:MM
        local part1=${BASH_REMATCH[1]}
        local part2=${BASH_REMATCH[2]}
        total_seconds=$((part1 * 60 + part2))
    elif [[ $input =~ ^([0-9]+)h$ ]]; then
        # Format: Xh
        local hours=${BASH_REMATCH[1]}
        total_seconds=$((hours * 3600))
    elif [[ $input =~ ^([0-9]+)m$ ]]; then
        # Format: Xm
        local minutes=${BASH_REMATCH[1]}
        total_seconds=$((minutes * 60))
    elif [[ $input =~ ^([0-9]+)s$ ]]; then
        # Format: Xs
        total_seconds=${BASH_REMATCH[1]}
    elif [[ $input =~ ^([0-9]+)$ ]]; then
        # Format: just numbers (assume seconds)
        total_seconds=$input
    else
        echo "❌ Invalid time format. Use: 25m, 1h, 30s, 25:00, or 1500"
        exit 1
    fi
    
    echo $total_seconds
}

# Function to format seconds to human readable
format_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    
    if [ $hours -gt 0 ]; then
        printf "%02d:%02d:%02d" $hours $minutes $seconds
    else
        printf "%02d:%02d" $minutes $seconds
    fi
}

# Main timer function
timer() {
    if [ -z "$1" ]; then
        echo "Usage: timer <time>"
        echo "Examples:"
        echo "  timer 25m    # 25 minutes"
        echo "  timer 1h     # 1 hour"
        echo "  timer 30s    # 30 seconds"
        echo "  timer 25:00  # 25 minutes"
        echo "  timer 1500   # 1500 seconds"
        return 1
    fi
    
    local total_seconds
    total_seconds=$(parse_time "$1")
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    echo "⏰ Timer started for $(format_time $total_seconds)"
    echo "🍅 Press Ctrl+C to stop the timer"
    echo ""
    
    # Countdown loop
    while [ $total_seconds -gt 0 ]; do
        # Clear line and show countdown
        printf "\r🕐 Time remaining: $(format_time $total_seconds)   "
        sleep 1
        ((total_seconds--))
    done
    
    # Timer finished
    echo ""
    echo ""
    echo "🎉 Timer finished!"
    echo "⏰ Time's up!"
    
    # Try to make a beep sound
    if command -v paplay >/dev/null 2>&1; then
        # Use system bell sound if available
        paplay /usr/share/sounds/alsa/Front_Left.wav 2>/dev/null ||
        paplay /usr/share/sounds/ubuntu/stereo/bell.ogg 2>/dev/null ||
        echo -e "\a"  # Terminal bell as fallback
    elif command -v aplay >/dev/null 2>&1; then
        # Alternative audio player
        aplay /usr/share/sounds/alsa/Front_Left.wav 2>/dev/null ||
        echo -e "\a"
    else
        # Terminal bell fallback
        echo -e "\a\a\a"  # Triple beep
    fi
    
    return 0
}

# If script is called directly (not sourced), run the timer
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    timer "$@"
fi
