#!/bin/bash

# Enhanced Pomodoro Setup Script
# This script sets up the complete Pomodoro work tracking system

echo "🍅 Enhanced Pomodoro Work Tracker Setup"
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_TRACKER_DIR="$HOME/work-tracker"

echo -e "${CYAN}📁 Script directory: $SCRIPT_DIR${NC}"
echo -e "${CYAN}🎯 Target directory: $WORK_TRACKER_DIR${NC}"
echo ""

# Step 1: Install required packages
echo -e "${YELLOW}📦 Step 1: Installing required packages...${NC}"

# Update package list
sudo apt update

# Install essential packages
PACKAGES=(
    "jq"           # JSON processor
    "espeak"       # Text-to-speech
    "curl"         # For API calls
    "git"          # Version control
    "nodejs"       # For task manager
    "npm"          # Node package manager
)

for package in "${PACKAGES[@]}"; do
    if ! command -v "$package" >/dev/null 2>&1; then
        echo -e "${BLUE}Installing $package...${NC}"
        sudo apt install -y "$package"
    else
        echo -e "${GREEN}✅ $package already installed${NC}"
    fi
done

# Step 2: Setup directory structure
echo ""
echo -e "${YELLOW}📁 Step 2: Setting up directory structure...${NC}"

# Create work tracker directory if it doesn't exist
if [ ! -d "$WORK_TRACKER_DIR" ]; then
    mkdir -p "$WORK_TRACKER_DIR"
    echo -e "${GREEN}✅ Created directory: $WORK_TRACKER_DIR${NC}"
else
    echo -e "${GREEN}✅ Directory already exists: $WORK_TRACKER_DIR${NC}"
fi

# Copy files to work tracker directory
echo -e "${BLUE}📋 Copying files...${NC}"

FILES_TO_COPY=(
    "index.html"
    "status.json"
    "daily-tasks.json"
    "pomo-history.json"
    "pomodoro.sh"
    "timer.sh"
    "task-manager.js"
    "deploy.sh"
    "README.md"
)

for file in "${FILES_TO_COPY[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        cp "$SCRIPT_DIR/$file" "$WORK_TRACKER_DIR/"
        echo -e "${GREEN}✅ Copied: $file${NC}"
    else
        echo -e "${YELLOW}⚠️  File not found: $file${NC}"
    fi
done

# Step 3: Make scripts executable
echo ""
echo -e "${YELLOW}🔧 Step 3: Making scripts executable...${NC}"

chmod +x "$WORK_TRACKER_DIR/pomodoro.sh"
chmod +x "$WORK_TRACKER_DIR/timer.sh"
chmod +x "$WORK_TRACKER_DIR/task-manager.js"
chmod +x "$WORK_TRACKER_DIR/deploy.sh"

echo -e "${GREEN}✅ Scripts made executable${NC}"

# Step 4: Setup shell integration
echo ""
echo -e "${YELLOW}🐚 Step 4: Setting up shell integration...${NC}"

BASHRC_LINE="source $WORK_TRACKER_DIR/pomodoro.sh"

# Check if already added to bashrc
if ! grep -q "$BASHRC_LINE" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Enhanced Pomodoro Work Tracker" >> ~/.bashrc
    echo "$BASHRC_LINE" >> ~/.bashrc
    echo -e "${GREEN}✅ Added to ~/.bashrc${NC}"
else
    echo -e "${GREEN}✅ Already added to ~/.bashrc${NC}"
fi

# Step 5: Initialize JSON files
echo ""
echo -e "${YELLOW}📄 Step 5: Initializing data files...${NC}"

# Initialize status.json if empty or doesn't exist
STATUS_FILE="$WORK_TRACKER_DIR/status.json"
if [ ! -s "$STATUS_FILE" ]; then
    cat > "$STATUS_FILE" << 'EOF'
{
  "session": "idle",
  "project": "",
  "start_time": null,
  "end_time": null
}
EOF
    echo -e "${GREEN}✅ Initialized status.json${NC}"
fi

# Initialize pomo-history.json if empty or doesn't exist
HISTORY_FILE="$WORK_TRACKER_DIR/pomo-history.json"
if [ ! -s "$HISTORY_FILE" ]; then
    cat > "$HISTORY_FILE" << 'EOF'
{
  "sessions": []
}
EOF
    echo -e "${GREEN}✅ Initialized pomo-history.json${NC}"
fi

# Step 6: Test the timer
echo ""
echo -e "${YELLOW}⏱️  Step 6: Testing timer functionality...${NC}"

echo -e "${BLUE}Testing 3-second timer...${NC}"
bash "$WORK_TRACKER_DIR/timer.sh" 3s

echo -e "${GREEN}✅ Timer test completed${NC}"

# Step 7: Setup git repository (optional)
echo ""
echo -e "${YELLOW}📚 Step 7: Git repository setup (optional)${NC}"

cd "$WORK_TRACKER_DIR"

if [ ! -d ".git" ]; then
    read -p "Would you like to initialize a git repository? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        git add .
        git commit -m "Initial commit: Enhanced Pomodoro Work Tracker"
        echo -e "${GREEN}✅ Git repository initialized${NC}"
        
        read -p "Enter your GitHub repository URL (optional): " REPO_URL
        if [ ! -z "$REPO_URL" ]; then
            git remote add origin "$REPO_URL"
            echo -e "${GREEN}✅ Remote repository added${NC}"
            echo -e "${BLUE}💡 Run 'git push -u origin main' to push to GitHub${NC}"
        fi
    fi
else
    echo -e "${GREEN}✅ Git repository already exists${NC}"
fi

# Step 8: Final instructions
echo ""
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo -e "${CYAN}🚀 Quick Start Guide:${NC}"
echo -e "${YELLOW}1. Restart your terminal or run:${NC} source ~/.bashrc"
echo -e "${YELLOW}2. Try these commands:${NC}"
echo "   pomo_help           # Show all commands"
echo "   wo modon            # Start work session on Modon project"
echo "   br                  # Start short break"
echo "   pomo_status         # Check current status"
echo ""
echo -e "${YELLOW}3. Task management:${NC}"
echo "   cd $WORK_TRACKER_DIR"
echo '   node task-manager.js add "Fix bug" backend high "Description here"'
echo "   node task-manager.js list"
echo ""
echo -e "${YELLOW}4. Open dashboard:${NC}"
echo "   cd $WORK_TRACKER_DIR"
echo "   python3 -m http.server 8000"
echo "   # Then open: http://localhost:8000"
echo ""
echo -e "${YELLOW}5. Deploy (after setting up git):${NC}"
echo "   ./deploy.sh git      # Deploy via git"
echo "   ./deploy.sh local    # Test locally"
echo ""
echo -e "${PURPLE}📍 All files are located in: $WORK_TRACKER_DIR${NC}"
echo -e "${BLUE}📖 Check README.md for detailed documentation${NC}"
echo ""
echo -e "${GREEN}Happy productivity! 🍅✨${NC}"
