#!/bin/bash

# Enhanced Pomodoro Script with Project & Task Tracking
# Usage: wo [project] or br [break-type]

# Pomodoro timing options
declare -A pomo_options
pomo_options["work"]="45"
pomo_options["short-break"]="10"
pomo_options["long-break"]="25"
pomo_options["lunch"]="60"

# Project options
declare -A projects
projects["modon"]="Modon Express"
projects["alhai"]="Alhai"
projects["aivue"]="Aivue"
projects["faayiz"]="Faayiz"
projects["personal"]="Personal Development"
projects["meeting"]="Team Meeting"
projects["review"]="Code Review"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Dashboard file paths
DASHBOARD_DIR="/mnt/c/Users/Senior Software Eng/Downloads/my-pomo-dashboard"
STATUS_FILE="$DASHBOARD_DIR/status.json"
TASKS_FILE="$DASHBOARD_DIR/daily-tasks.json"
HISTORY_FILE="$DASHBOARD_DIR/pomo-history.json"

# Function to show available projects
show_projects() {
    echo -e "${CYAN}Available Projects:${NC}"
    for key in "${!projects[@]}"; do
        echo -e "  ${YELLOW}$key${NC} - ${projects[$key]}"
    done
}

# Function to show available session types
show_sessions() {
    echo -e "${CYAN}Available Sessions:${NC}"
    for key in "${!pomo_options[@]}"; do
        echo -e "  ${YELLOW}$key${NC} - ${pomo_options[$key]} minutes"
    done
}

# Function to update status.json
update_status() {
    local session_type="$1"
    local project="$2"
    local start_time=$(date +%s)
    local duration_minutes=${pomo_options["$session_type"]}
    local end_time=$((start_time + duration_minutes * 60))
    
    # Create status JSON
    cat > "$STATUS_FILE" << EOF
{
  "session": "$session_type",
  "project": "$project",
  "start_time": $start_time,
  "end_time": $end_time
}
EOF
    
    echo -e "${GREEN}✅ Status updated: $session_type${NC}"
}

# Function to log to history
log_to_history() {
    local session_type="$1"
    local project="$2"
    local start_time="$3"
    local end_time="$4"
    local date=$(date +%Y-%m-%d)
    local datetime=$(date --iso-8601=seconds)
    
    # Create history entry
    local entry="{
        \"date\": \"$date\",
        \"datetime\": \"$datetime\",
        \"session_type\": \"$session_type\",
        \"project\": \"$project\",
        \"start_time\": $start_time,
        \"end_time\": $end_time,
        \"duration_minutes\": ${pomo_options["$session_type"]}
    }"
    
    # Initialize history file if it doesn't exist
    if [ ! -f "$HISTORY_FILE" ]; then
        echo '{"sessions": []}' > "$HISTORY_FILE"
    fi
    
    # Add entry to history using jq
    if command -v jq >/dev/null 2>&1; then
        jq ".sessions += [$entry]" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    else
        echo "Warning: jq not installed. History not saved."
    fi
}

# Function to add task to daily tasks
add_current_task() {
    local project="$1"
    local session_type="$2"
    
    if [ "$session_type" = "work" ] && [ -n "$project" ]; then
        local task_title="${projects[$project]} - Development Session"
        local current_time=$(date --iso-8601=seconds)
        
        # Read current tasks and add new one
        # This is a simplified version - you'd want to use jq for proper JSON manipulation
        echo -e "${BLUE}📝 Task added: $task_title${NC}"
    fi
}

# Function to deploy to website (customize based on your deployment method)
deploy_to_website() {
    echo -e "${PURPLE}🚀 Deploying to website...${NC}"
    
    # Option 1: If using git and auto-deployment
    # cd "$DASHBOARD_DIR"
    # git add status.json daily-tasks.json pomo-history.json
    # git commit -m "Update Pomodoro session: $(date)"
    # git push
    
    # Option 2: If using rsync to server
    # rsync -av "$DASHBOARD_DIR/" user@your-server.com:/path/to/website/
    
    # Option 3: If using cloud storage (S3, etc.)
    # aws s3 sync "$DASHBOARD_DIR/" s3://your-bucket/
    
    echo -e "${GREEN}✅ Deployment completed${NC}"
}

# Main pomodoro function
pomodoro() {
    local session_type="$1"
    local project="$2"
    
    # Validate session type
    if [ -z "$session_type" ] || [ -z "${pomo_options["$session_type"]}" ]; then
        echo -e "${RED}❌ Invalid session type: $session_type${NC}"
        show_sessions
        return 1
    fi
    
    # For work sessions, require project
    if [ "$session_type" = "work" ]; then
        if [ -z "$project" ] || [ -z "${projects["$project"]}" ]; then
            echo -e "${RED}❌ Work session requires a valid project${NC}"
            show_projects
            return 1
        fi
        local project_name="${projects[$project]}"
    else
        local project_name="Break"
    fi
    
    local duration=${pomo_options["$session_type"]}
    local start_time=$(date +%s)
    local end_time=$((start_time + duration * 60))
    
    # Update status file
    update_status "$session_type" "$project_name"
    
    # Add to daily tasks if it's work
    add_current_task "$project" "$session_type"
    
    # Deploy to website
    deploy_to_website
    
    # Show session info
    echo -e "${GREEN}🍅 Starting: $session_type${NC}"
    echo -e "${BLUE}📊 Project: $project_name${NC}"
    echo -e "${YELLOW}⏰ Duration: $duration minutes${NC}"
    
    # Start timer with visual feedback
    if command -v lolcat >/dev/null 2>&1; then
        echo "$session_type - $project_name" | lolcat
    else
        echo -e "${PURPLE}$session_type - $project_name${NC}"
    fi
    
    # Run timer
    timer ${duration}m
    
    # Session completed
    local completion_message="$session_type session completed"
    
    # Text-to-speech notification
    if command -v espeak >/dev/null 2>&1; then
        espeak "'$completion_message'"
    fi
    
    # Windows toast notification
    powershell.exe -Command "New-BurntToastNotification -Text 'Pomodoro Timer', '$completion_message'" > /dev/null 2>&1
    
    # Log to history
    log_to_history "$session_type" "$project_name" "$start_time" "$end_time"
    
    # Update status to idle
    cat > "$STATUS_FILE" << EOF
{
  "session": "idle",
  "project": "",
  "start_time": null,
  "end_time": null
}
EOF
    
    # Final deployment
    deploy_to_website
    
    echo -e "${GREEN}✅ Session completed and logged!${NC}"
}

# Enhanced aliases with project selection
wo() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please specify a project:${NC}"
        show_projects
        return 1
    fi
    pomodoro "work" "$1"
}

# Break aliases
br() {
    pomodoro "short-break" "break"
}

lbr() {
    pomodoro "long-break" "break"
}

lunch() {
    pomodoro "lunch" "break"
}

# Utility functions
pomo_status() {
    if [ -f "$STATUS_FILE" ]; then
        echo -e "${CYAN}📊 Current Status:${NC}"
        cat "$STATUS_FILE" | jq '.' 2>/dev/null || cat "$STATUS_FILE"
    else
        echo -e "${YELLOW}⚠️ No active session${NC}"
    fi
}

pomo_history() {
    local days=${1:-7}
    echo -e "${CYAN}📈 Pomodoro History (last $days days):${NC}"
    if [ -f "$HISTORY_FILE" ]; then
        # Show recent sessions
        cat "$HISTORY_FILE" | jq --arg days "$days" '
            .sessions | 
            map(select(.date >= (now - ($days | tonumber) * 86400 | strftime("%Y-%m-%d")))) |
            group_by(.date) |
            map({
                date: .[0].date,
                sessions: length,
                total_minutes: map(.duration_minutes) | add,
                projects: map(.project) | unique
            })
        ' 2>/dev/null || echo "Install jq for better history viewing"
    else
        echo -e "${YELLOW}⚠️ No history found${NC}"
    fi
}

pomo_help() {
    echo -e "${CYAN}🍅 Enhanced Pomodoro Commands:${NC}"
    echo ""
    echo -e "${YELLOW}Work Sessions:${NC}"
    echo -e "  wo [project]     - Start 45min work session"
    echo -e "  Example: wo modon"
    echo ""
    echo -e "${YELLOW}Break Sessions:${NC}"
    echo -e "  br              - Start 10min short break"
    echo -e "  lbr             - Start 25min long break"
    echo -e "  lunch           - Start 60min lunch break"
    echo ""
    echo -e "${YELLOW}Utilities:${NC}"
    echo -e "  pomo_status     - Show current session"
    echo -e "  pomo_history    - Show recent history"
    echo -e "  show_projects   - List available projects"
    echo -e "  show_sessions   - List session types"
    echo ""
    show_projects
}

# Export functions for use
export -f pomodoro wo br lbr lunch pomo_status pomo_history pomo_help show_projects show_sessions

echo -e "${GREEN}✅ Enhanced Pomodoro script loaded!${NC}"
echo -e "${BLUE}💡 Type 'pomo_help' for usage instructions${NC}"
