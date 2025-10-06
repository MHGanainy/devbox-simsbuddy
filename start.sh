#!/bin/bash

# Change to the script's directory
cd "$(dirname "$0")"
SCRIPT_DIR=$(pwd)

# Create logs directory if it doesn't exist
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# Log file with timestamp
LOG_FILE="$LOG_DIR/sync_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Logging function
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" >> "$LOG_FILE"
    echo -e "$message"
}

log_success() {
    local message="${GREEN}✅ $1${NC}"
    log "$message"
}

log_error() {
    local message="${RED}❌ ERROR: $1${NC}"
    log "$message"
}

log_warning() {
    local message="${YELLOW}⚠️  WARNING: $1${NC}"
    log "$message"
}

log_info() {
    local message="${CYAN}ℹ️  $1${NC}"
    log "$message"
}

log_highlight() {
    local message="${MAGENTA}★ $1${NC}"
    log "$message"
}

echo "======================================="
echo "   Starting Development Environment"
echo "======================================="
echo ""
log_info "Log file: $LOG_FILE"
echo ""

# Check prerequisites
log "Checking prerequisites..."
if command -v git &> /dev/null; then
    log_success "Git is installed"
else
    log_error "Git is not installed!"
    exit 1
fi

if command -v docker &> /dev/null; then
    log_success "Docker is installed"
else
    log_error "Docker is not installed!"
    exit 1
fi

if docker info > /dev/null 2>&1; then
    log_success "Docker Desktop is running"
else
    log_error "Docker Desktop is not running!"
    exit 1
fi

echo ""

# Git Protocol Selection
echo -e "${BLUE}=======================================${NC}"
echo -e "${YELLOW}Select Git Protocol:${NC}"
echo -e "${BLUE}=======================================${NC}"
echo "1) HTTPS (easier, works immediately)"
echo "2) SSH (faster, requires SSH key setup)"
echo ""
read -p "Enter your choice (1 or 2): " git_choice

case $git_choice in
    1)
        log_success "Using HTTPS for Git"
        FRONTEND_REPO="https://github.com/omarelmoghazy/simsbuddy.git"
        BACKEND_REPO="https://github.com/MHGanainy/mvp-backend.git"
        VOICE_REPO="https://github.com/MHGanainy/realtime-voice-assistant.git"
        ;;
    2)
        log_success "Using SSH for Git"
        # Check if SSH key exists
        if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
            log_warning "No SSH key found. Please run setup-github-ssh.sh first"
            exit 1
        fi
        FRONTEND_REPO="git@github.com:omarelmoghazy/simsbuddy.git"
        BACKEND_REPO="git@github.com:MHGanainy/mvp-backend.git"
        VOICE_REPO="git@github.com:MHGanainy/realtime-voice-assistant.git"
        ;;
    *)
        log_warning "Invalid choice. Defaulting to HTTPS"
        FRONTEND_REPO="https://github.com/omarelmoghazy/simsbuddy.git"
        BACKEND_REPO="https://github.com/MHGanainy/mvp-backend.git"
        VOICE_REPO="https://github.com/MHGanainy/realtime-voice-assistant.git"
        ;;
esac

echo ""

# Function to compare commits between branches
compare_branches() {
    local branch1=$1
    local branch2=$2
    local label=$3
    
    # Get commit hashes
    local hash1=$(git rev-parse $branch1 2>/dev/null)
    local hash2=$(git rev-parse $branch2 2>/dev/null)
    
    if [ -z "$hash1" ] || [ -z "$hash2" ]; then
        log_warning "Could not compare branches (one or both branches missing)"
        return 1
    fi
    
    # Get short hashes for display
    local short_hash1=$(git rev-parse --short $branch1 2>/dev/null)
    local short_hash2=$(git rev-parse --short $branch2 2>/dev/null)
    
    log_info "$label Comparison:"
    log "  $branch1: $short_hash1"
    log "  $branch2: $short_hash2"
    
    if [ "$hash1" = "$hash2" ]; then
        log_success "Branches are synchronized (same commit)"
        return 0
    else
        # Check if one is ahead of the other
        local ahead=$(git rev-list --count $branch2..$branch1 2>/dev/null || echo "0")
        local behind=$(git rev-list --count $branch1..$branch2 2>/dev/null || echo "0")
        
        if [ "$ahead" = "0" ] && [ "$behind" != "0" ]; then
            log_warning "devbox is $behind commits behind main"
        elif [ "$ahead" != "0" ] && [ "$behind" = "0" ]; then
            log_info "devbox is $ahead commits ahead of main"
        elif [ "$ahead" != "0" ] && [ "$behind" != "0" ]; then
            log_warning "Branches have diverged: devbox is $ahead ahead, $behind behind main"
        fi
        
        # Show last commit message for each
        log "  Last commit on $branch1:"
        git log -1 --oneline $branch1 | while read line; do
            log "    $line"
        done
        log "  Last commit on $branch2:"
        git log -1 --oneline $branch2 | while read line; do
            log "    $line"
        done
        
        return 1
    fi
}

# Function to setup and update devbox branch with proper syncing
setup_devbox_branch() {
    local repo_name=$1
    local repo_url=$2
    local dir_name=$3
    local original_dir=$(pwd)  # Save current directory
    
    echo ""
    echo -e "${BLUE}=======================================${NC}"
    log_info "Setting up $repo_name..."
    echo -e "${BLUE}=======================================${NC}"
    
    if [ ! -d "$dir_name" ]; then
        log "Repository $dir_name doesn't exist. Cloning..."
        log "Cloning $repo_name repository (attempting devbox branch)..."
        
        # Try to clone devbox branch first
        git clone -b devbox "$repo_url" "$dir_name" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            log_warning "devbox branch doesn't exist, cloning main and creating devbox..."
            git clone "$repo_url" "$dir_name"
            
            if [ $? -eq 0 ]; then
                cd "$dir_name"
                log "Creating devbox branch from main..."
                git checkout -b devbox
                
                # Push the new devbox branch to origin
                log "Pushing new devbox branch to origin..."
                git push -u origin devbox 2>&1 | tee -a "$LOG_FILE"
                
                if [ ${PIPESTATUS[0]} -eq 0 ]; then
                    log_success "$repo_name devbox branch created and pushed"
                else
                    log_warning "Failed to push devbox branch - may need authentication"
                fi
                cd "$original_dir"
            else
                log_error "Failed to clone $repo_name"
                cd "$original_dir"
                return 1
            fi
        else
            log_success "$repo_name cloned successfully (devbox branch)"
        fi
    else
        log "Repository $dir_name exists. Updating..."
        cd "$dir_name"
        
        # Get current branch
        current_branch=$(git branch --show-current)
        log "Current branch: $current_branch"
        
        # Stash any local changes
        if git diff --quiet && git diff --cached --quiet; then
            log "No local changes detected"
        else
            log_warning "Stashing local changes..."
            git stash push -m "Auto-stash before sync $(date +%Y%m%d_%H%M%S)"
        fi
        
        # Ensure we're on devbox branch
        if [ "$current_branch" != "devbox" ]; then
            log "Switching to devbox branch..."
            git checkout devbox 2>&1 | tee -a "$LOG_FILE"
            
            if [ ${PIPESTATUS[0]} -ne 0 ]; then
                log "devbox branch doesn't exist locally, creating it..."
                git checkout -b devbox 2>&1 | tee -a "$LOG_FILE"
            fi
        fi
        
        # Fetch all remote branches
        log "Fetching all remote branches..."
        git fetch --all --prune 2>&1 | tee -a "$LOG_FILE"
        
        # Pull latest devbox changes
        log "Pulling latest devbox branch changes..."
        git pull origin devbox 2>&1 | tee -a "$LOG_FILE"
        pull_result=${PIPESTATUS[0]}
        
        if [ $pull_result -ne 0 ]; then
            log_warning "devbox branch doesn't exist on remote or no changes to pull"
        fi
        
        # Get the latest main branch changes locally
        log "Fetching latest main branch..."
        git fetch origin main:main 2>&1 | tee -a "$LOG_FILE"
        
        echo ""
        log_highlight "=== PRE-MERGE STATUS for $repo_name ==="
        compare_branches "devbox" "origin/main" "Before Merge"
        local branches_synced_before=$?
        echo ""
        
        if [ $branches_synced_before -eq 0 ]; then
            log_success "Branches already synchronized, no merge needed"
        else
            # Merge main into devbox
            log "Merging main branch into devbox..."
            git merge origin/main -m "Sync devbox with main $(date +%Y-%m-%d)" 2>&1 | tee -a "$LOG_FILE"
            merge_result=${PIPESTATUS[0]}
            
            if [ $merge_result -eq 0 ]; then
                log_success "Successfully merged main into devbox for $repo_name"
                
                echo ""
                log_highlight "=== POST-MERGE STATUS for $repo_name ==="
                compare_branches "devbox" "origin/main" "After Merge"
                local branches_synced_after=$?
                echo ""
                
                if [ $branches_synced_after -eq 0 ]; then
                    log_success "✨ Merge successful - branches are now synchronized!"
                else
                    log_info "Merge completed but devbox has additional commits not in main"
                fi
                
                # Push the updated devbox branch back to origin
                log "Pushing updated devbox branch to origin..."
                git push origin devbox 2>&1 | tee -a "$LOG_FILE"
                
                if [ ${PIPESTATUS[0]} -eq 0 ]; then
                    log_success "$repo_name devbox branch synced and pushed to origin"
                    
                    # Show merge summary
                    log "Merge summary - recent commits on devbox:"
                    git log --oneline -5 | while read line; do
                        log "  $line"
                    done
                else
                    log_error "Failed to push devbox branch - check authentication"
                fi
            else
                log_error "Merge conflicts detected in $repo_name"
                log "Attempting to resolve by accepting incoming changes from main..."
                
                # Show conflict status
                log "Conflicted files:"
                git diff --name-only --diff-filter=U | while read file; do
                    log "  - $file"
                done
                
                # Abort the merge and try again with strategy
                git merge --abort 2>/dev/null
                
                log "Retrying merge with 'theirs' strategy (accept main changes)..."
                git merge origin/main -X theirs -m "Force sync devbox with main (accepted main changes) $(date +%Y-%m-%d)" 2>&1 | tee -a "$LOG_FILE"
                
                if [ ${PIPESTATUS[0]} -eq 0 ]; then
                    log_success "Resolved conflicts by accepting main branch changes"
                    
                    echo ""
                    log_highlight "=== POST-CONFLICT-RESOLUTION STATUS for $repo_name ==="
                    compare_branches "devbox" "origin/main" "After Conflict Resolution"
                    echo ""
                    
                    # Push the resolved merge
                    git push origin devbox 2>&1 | tee -a "$LOG_FILE"
                    
                    if [ ${PIPESTATUS[0]} -eq 0 ]; then
                        log_success "$repo_name devbox branch synced (with conflict resolution) and pushed"
                    else
                        log_error "Failed to push resolved changes"
                    fi
                else
                    log_error "Could not automatically resolve conflicts for $repo_name"
                    log "Manual intervention required. Resetting to remote devbox..."
                    git reset --hard origin/devbox
                fi
            fi
        fi
        
        # Check if there are stashed changes to restore
        if git stash list | grep -q "Auto-stash before sync"; then
            log "Attempting to restore stashed changes..."
            git stash pop 2>&1 | tee -a "$LOG_FILE"
            
            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                log_success "Restored local changes"
            else
                log_warning "Could not automatically restore local changes - check git stash list"
            fi
        fi
        
        cd "$original_dir"
    fi
    
    echo ""
}

# Function to generate sync summary
generate_summary() {
    echo ""
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${GREEN}📊 FINAL SYNC SUMMARY${NC}"
    echo -e "${BLUE}=======================================${NC}"
    
    local all_synced=true
    
    for dir in frontend backend voice-agent; do
        if [ -d "$dir" ]; then
            cd "$dir"
            echo ""
            echo -e "${YELLOW}📁 $dir:${NC}"
            
            # Fetch latest to ensure accurate comparison
            git fetch --all --quiet 2>/dev/null
            
            current_branch=$(git branch --show-current)
            echo "  Current branch: $current_branch"
            
            # Get commit hashes
            local devbox_hash=$(git rev-parse --short devbox 2>/dev/null)
            local main_hash=$(git rev-parse --short origin/main 2>/dev/null)
            
            echo "  devbox HEAD: $devbox_hash"
            echo "  main HEAD:   $main_hash"
            
            if [ "$devbox_hash" = "$main_hash" ]; then
                echo -e "  ${GREEN}✅ Status: SYNCHRONIZED${NC}"
            else
                echo -e "  ${YELLOW}⚠️  Status: DIVERGED${NC}"
                all_synced=false
                
                # Show divergence details
                local ahead=$(git rev-list --count origin/main..devbox 2>/dev/null || echo "0")
                local behind=$(git rev-list --count devbox..origin/main 2>/dev/null || echo "0")
                
                if [ "$behind" != "0" ]; then
                    echo -e "  ${RED}Behind main by $behind commits${NC}"
                fi
                if [ "$ahead" != "0" ]; then
                    echo -e "  ${CYAN}Ahead of main by $ahead commits${NC}"
                fi
            fi
            
            # Show last commit
            last_commit=$(git log -1 --oneline devbox)
            echo "  Last commit: $last_commit"
            
            cd "$SCRIPT_DIR"
        fi
    done
    
    echo ""
    if [ "$all_synced" = true ]; then
        echo -e "${GREEN}✨ All repositories are synchronized with main!${NC}"
    else
        echo -e "${YELLOW}⚠️  Some repositories are not fully synchronized${NC}"
        echo "  Run this script again to attempt another sync"
    fi
    echo -e "${BLUE}=======================================${NC}"
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
        log_success "Using Local PostgreSQL"
        COMPOSE_FILE="docker-compose.local.yml"
        DB_NAME="Local PostgreSQL"
        ;;
    2)
        log_success "Using Railway Cloud Database"
        COMPOSE_FILE="docker-compose.cloud.yml"
        DB_NAME="Railway Cloud"
        ;;
    *)
        log_error "Invalid choice. Defaulting to Local PostgreSQL"
        COMPOSE_FILE="docker-compose.local.yml"
        DB_NAME="Local PostgreSQL"
        ;;
esac

echo ""
echo -e "${BLUE}=======================================${NC}"
echo -e "${YELLOW}🔄 Managing devbox branches...${NC}"
echo -e "${BLUE}=======================================${NC}"

# Setup/update each repository's devbox branch
setup_devbox_branch "Frontend" "$FRONTEND_REPO" "frontend"
setup_devbox_branch "Backend" "$BACKEND_REPO" "backend"
setup_devbox_branch "Voice Agent" "$VOICE_REPO" "voice-agent"

# Generate final summary
generate_summary

# Check if all repositories exist before starting Docker
if [ ! -d "frontend" ] || [ ! -d "backend" ] || [ ! -d "voice-agent" ]; then
    echo ""
    log_error "Not all repositories were cloned successfully"
    log "Please check the log file: $LOG_FILE"
    exit 1
fi

echo ""
echo "======================================="
echo "Starting all services..."
echo "======================================="
echo ""
log_info "Database: $DB_NAME"
log_info "Branch: devbox (synced with main)"
log_info "Log file: $LOG_FILE"
echo ""
echo "Services will be available at:"
echo "  📱 Frontend:    http://localhost:5173"
echo "  ⚡ Backend API: http://localhost:3000"
echo "  🎤 Voice Agent: http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Make sure we're in the script directory before running docker-compose
cd "$SCRIPT_DIR"
log "Starting Docker Compose with $COMPOSE_FILE..."
docker-compose -f "./${COMPOSE_FILE}" up