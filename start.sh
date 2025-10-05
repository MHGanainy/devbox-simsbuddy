#!/bin/bash

# Change to the script's directory
cd "$(dirname "$0")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "======================================="
echo "   Starting Development Environment"
echo "======================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if command -v git &> /dev/null; then
    echo -e "${GREEN}✅ Git is installed${NC}"
else
    echo -e "${RED}❌ ERROR: Git is not installed!${NC}"
    exit 1
fi

if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker is installed${NC}"
else
    echo -e "${RED}❌ ERROR: Docker is not installed!${NC}"
    exit 1
fi

if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker Desktop is running${NC}"
else
    echo -e "${RED}❌ ERROR: Docker Desktop is not running!${NC}"
    exit 1
fi

echo ""

# Function to setup and update devbox branch
setup_devbox_branch() {
    local repo_name=$1
    local repo_url=$2
    local dir_name=$3
    
    echo -e "${YELLOW}Setting up $repo_name...${NC}"
    
    if [ ! -d "$dir_name" ]; then
        echo "Cloning $repo_name repository (devbox branch)..."
        git clone -b devbox "$repo_url" "$dir_name" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}devbox branch doesn't exist, cloning main and creating devbox...${NC}"
            git clone "$repo_url" "$dir_name"
            cd "$dir_name"
            git checkout -b devbox
            cd ..
        fi
    else
        echo "Updating $repo_name repository..."
        cd "$dir_name"
        
        # Ensure we're on devbox branch
        current_branch=$(git branch --show-current)
        if [ "$current_branch" != "devbox" ]; then
            echo "Switching to devbox branch..."
            git checkout devbox 2>/dev/null || git checkout -b devbox
        fi
        
        # Fetch latest changes
        echo "Fetching latest changes..."
        git fetch origin
        
        # Merge main into devbox to keep it up to date
        echo "Syncing with main branch..."
        git merge origin/main --no-edit 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ $repo_name synced with main${NC}"
        else
            echo -e "${YELLOW}⚠️  Merge conflicts detected in $repo_name${NC}"
            echo "Attempting to resolve automatically..."
            git merge --abort
            git reset --hard origin/devbox
            echo -e "${YELLOW}Reset to remote devbox. Manual merge with main may be needed.${NC}"
        fi
        
        cd ..
    fi
}

# Database Selection
echo -e "${BLUE}=======================================${NC}"
echo -e "${YELLOW}Select Database Option:${NC}"
echo -e "${BLUE}=======================================${NC}"
echo "1) Local PostgreSQL (Docker)"
echo "2) Railway Cloud Database"
echo ""
read -p "Enter your choice (1 or 2): " db_choice

case $db_choice in
    1)
        echo -e "${GREEN}✅ Using Local PostgreSQL${NC}"
        COMPOSE_FILE="docker-compose.local.yml"
        DB_NAME="Local PostgreSQL"
        ;;
    2)
        echo -e "${GREEN}✅ Using Railway Cloud Database${NC}"
        COMPOSE_FILE="docker-compose.cloud.yml"
        DB_NAME="Railway Cloud"
        ;;
    *)
        echo -e "${RED}Invalid choice. Defaulting to Local PostgreSQL${NC}"
        COMPOSE_FILE="docker-compose.local.yml"
        DB_NAME="Local PostgreSQL"
        ;;
esac

echo ""
echo -e "${BLUE}=======================================${NC}"
echo -e "${YELLOW}Managing devbox branches...${NC}"
echo -e "${BLUE}=======================================${NC}"

# Setup/update each repository's devbox branch
setup_devbox_branch "Frontend" "git@github.com:omarelmoghazy/simsbuddy.git" "frontend"
setup_devbox_branch "Backend" "git@github.com:MHGanainy/mvp-backend.git" "backend"
setup_devbox_branch "Voice Agent" "git@github.com:MHGanainy/realtime-voice-assistant.git" "voice-agent"

echo ""
echo "======================================="
echo "Starting all services..."
echo "======================================="
echo ""
echo -e "${YELLOW}Database:${NC} $DB_NAME"
echo -e "${YELLOW}Branch:${NC} devbox (synced with main)"
echo ""
echo "Services will be available at:"
echo "  📱 Frontend:    http://localhost:5173"
echo "  ⚡ Backend API: http://localhost:3000"
echo "  🎤 Voice Agent: http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

docker-compose -f $COMPOSE_FILE up