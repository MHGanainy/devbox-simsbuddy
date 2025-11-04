#!/bin/bash

################################################################################
#                   SimsBuddy Staging - Update Manager                         #
#                      Selective Repository Updates                            #
################################################################################

# Change to the script's directory
cd "$(dirname "$0")"
SCRIPT_DIR=$(pwd)

# Create logs directory
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/update_$(date +%Y%m%d_%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Emojis
CHECK="✅"
CROSS="❌"
WARN="⚠️"
INFO="ℹ️"
ROCKET="🚀"
REFRESH="🔄"
CLOCK="⏱️"
PACKAGE="📦"
FIRE="🔥"
SAVE="💾"

# Logging functions
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" >> "$LOG_FILE"
    echo -e "$message"
}

log_success() {
    log "${GREEN}${CHECK} $1${NC}"
}

log_error() {
    log "${RED}${CROSS} $1${NC}"
}

log_warning() {
    log "${YELLOW}${WARN} $1${NC}"
}

log_info() {
    log "${CYAN}${INFO} $1${NC}"
}

# Welcome banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║              ${BOLD}SimsBuddy - Update Manager${NC}${CYAN}                     ║"
    echo "║                                                                ║"
    echo "║           Keep your staging code up to date ${REFRESH}                ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    log_info "Update session started at $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "Log file: $LOG_FILE"
    echo ""
}

# Check repository status
check_repo_status() {
    local repo_name=$1
    local dir_name=$2

    if [ ! -d "$dir_name" ]; then
        echo -e "  ${RED}${CROSS} Not found${NC}"
        return 1
    fi

    cd "$dir_name"

    local current_branch=$(git branch --show-current)
    local current_hash=$(git rev-parse --short HEAD)
    local last_commit=$(git log -1 --pretty=format:"%s" 2>/dev/null)

    # Fetch to check for updates
    git fetch origin staging --quiet 2>&1 >> "$LOG_FILE"

    local local_hash=$(git rev-parse --short staging 2>/dev/null)
    local remote_hash=$(git rev-parse --short origin/staging 2>/dev/null)

    # Check for uncommitted changes
    local has_changes=false
    if ! git diff --quiet || ! git diff --cached --quiet; then
        has_changes=true
    fi

    # Check how many commits behind
    local commits_behind=0
    if [ "$local_hash" != "$remote_hash" ]; then
        commits_behind=$(git rev-list --count staging..origin/staging 2>/dev/null || echo "0")
    fi

    echo -e "${YELLOW}${BOLD}$repo_name:${NC}"
    echo -e "  Branch:  ${CYAN}$current_branch${NC}"
    echo -e "  Commit:  ${CYAN}$current_hash${NC}"
    echo -e "  Message: ${CYAN}$last_commit${NC}"

    if [ "$has_changes" = true ]; then
        echo -e "  Changes: ${YELLOW}${WARN} Uncommitted local changes${NC}"
    fi

    if [ "$commits_behind" -gt 0 ]; then
        echo -e "  Status:  ${YELLOW}${WARN} $commits_behind commits behind${NC}"
        UPDATES_AVAILABLE=true
    else
        echo -e "  Status:  ${GREEN}${CHECK} Up to date${NC}"
    fi

    echo ""
    cd "$SCRIPT_DIR"
}

# Show current status
show_status() {
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  ${INFO} CURRENT STATUS${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    UPDATES_AVAILABLE=false

    check_repo_status "Frontend" "frontend"
    check_repo_status "Backend" "backend"
    check_repo_status "Voice Agent" "voice-agent"

    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Update repository
update_repo() {
    local repo_name=$1
    local dir_name=$2

    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  ${REFRESH} Updating $repo_name${NC}"
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ ! -d "$dir_name" ]; then
        log_error "$dir_name directory not found"
        echo ""
        return 1
    fi

    cd "$dir_name"

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log_warning "Uncommitted changes detected"
        echo ""
        echo -e "${YELLOW}  Modified files:${NC}"
        git status --short | sed 's/^/    /'
        echo ""
        echo -e "${CYAN}  Do you want to see the changes? (y/n)${NC}"
        read -p "  " show_diff
        if [[ "$show_diff" =~ ^[Yy]$ ]]; then
            echo ""
            git diff --stat
            echo ""
        fi

        echo -e "${CYAN}  How to proceed?${NC}"
        echo -e "    ${BLUE}1)${NC} Stash changes and update (recommended)"
        echo -e "    ${BLUE}2)${NC} Discard changes and update"
        echo -e "    ${BLUE}3)${NC} Skip this update"
        echo ""
        read -p "  Enter choice (1-3): " change_choice

        case $change_choice in
            1)
                echo ""
                log_info "Stashing changes..."
                git stash push -m "Update manager stash $(date +%Y%m%d_%H%M%S)" 2>&1 | tee -a "$LOG_FILE"
                STASHED=true
                ;;
            2)
                echo ""
                log_warning "Discarding local changes..."
                git reset --hard HEAD 2>&1 >> "$LOG_FILE"
                STASHED=false
                ;;
            3)
                echo ""
                log_info "Skipping update for $repo_name"
                cd "$SCRIPT_DIR"
                return 0
                ;;
            *)
                log_error "Invalid choice. Skipping update."
                cd "$SCRIPT_DIR"
                return 1
                ;;
        esac
    else
        STASHED=false
    fi

    # Ensure on staging branch
    local current_branch=$(git branch --show-current)
    if [ "$current_branch" != "staging" ]; then
        log_warning "Not on staging branch (currently on $current_branch)"
        echo -e "${CYAN}  Switch to staging branch? (y/n)${NC}"
        read -p "  " switch_branch
        if [[ "$switch_branch" =~ ^[Yy]$ ]]; then
            git checkout staging 2>&1 | tee -a "$LOG_FILE"
        else
            log_info "Staying on $current_branch"
            cd "$SCRIPT_DIR"
            return 1
        fi
    fi

    # Get current state
    local old_hash=$(git rev-parse --short HEAD)

    # Show what will be updated
    echo ""
    log_info "Checking for updates from origin/staging..."
    git fetch origin staging 2>&1 >> "$LOG_FILE"

    local new_hash=$(git rev-parse --short origin/staging)
    local commits_behind=$(git rev-list --count staging..origin/staging 2>/dev/null || echo "0")

    if [ "$commits_behind" -eq 0 ]; then
        log_success "Already up to date!"
        cd "$SCRIPT_DIR"
        return 0
    fi

    echo ""
    log_info "$commits_behind new commits available"
    echo ""
    echo -e "${CYAN}  New commits to be pulled:${NC}"
    echo ""
    git log --oneline --decorate --graph staging..origin/staging | head -10 | sed 's/^/    /'
    echo ""

    echo -e "${CYAN}  Proceed with update? (y/n)${NC}"
    read -p "  " proceed
    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        log_info "Update cancelled"
        cd "$SCRIPT_DIR"
        return 0
    fi

    # Pull changes
    echo ""
    log_info "Pulling changes from origin/staging..."
    git pull origin staging 2>&1 | tee -a "$LOG_FILE"

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo ""
        log_success "Updated from $old_hash to $new_hash"

        # Show summary
        echo ""
        echo -e "${CYAN}  ${INFO} What changed:${NC}"
        git log --oneline $old_hash..HEAD | head -5 | sed 's/^/    /'
        echo ""
    else
        echo ""
        log_error "Update failed - check logs"
        cd "$SCRIPT_DIR"
        return 1
    fi

    # Restore stashed changes
    if [ "$STASHED" = true ]; then
        echo ""
        log_info "Restoring your local changes..."
        git stash pop 2>&1 | tee -a "$LOG_FILE"

        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_success "Changes restored successfully"
        else
            log_warning "Conflict while restoring changes - check git stash list"
        fi
    fi

    cd "$SCRIPT_DIR"
    echo ""
    return 0
}

# Restart service
restart_service() {
    local service_name=$1

    echo -e "${CYAN}  ${service_name^} was updated. Restart the service? (y/n)${NC}"
    read -p "  " restart_choice

    if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
        echo ""
        log_info "Restarting $service_name service..."
        docker-compose -f docker-compose.staging.yml restart $service_name 2>&1 | tee -a "$LOG_FILE"

        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            echo ""
            log_success "$service_name restarted successfully"
            echo ""
            echo -e "${CYAN}  ${INFO} Waiting for service to initialize (10 seconds)...${NC}"
            sleep 10

            # Verify service is running
            case $service_name in
                frontend)
                    if curl -s -I http://localhost:5173 > /dev/null 2>&1; then
                        log_success "Frontend is responding at http://localhost:5173"
                    else
                        log_warning "Frontend may still be starting up"
                    fi
                    ;;
                backend)
                    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
                        log_success "Backend is responding at http://localhost:3000"
                    else
                        log_warning "Backend may still be starting up"
                    fi
                    ;;
                voice-agent)
                    if curl -s http://localhost:8000/ > /dev/null 2>&1; then
                        log_success "Voice-agent is responding at http://localhost:8000"
                    else
                        log_warning "Voice-agent may still be starting up"
                    fi
                    ;;
            esac
        else
            echo ""
            log_error "Failed to restart $service_name"
        fi
    else
        echo ""
        log_info "Skipped restart - remember to restart manually if needed"
    fi
    echo ""
}

# Interactive menu
show_menu() {
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  ${PACKAGE} UPDATE OPTIONS${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BLUE}[1]${NC} Update all repositories"
    echo -e "  ${BLUE}[2]${NC} Update frontend only"
    echo -e "  ${BLUE}[3]${NC} Update backend only"
    echo -e "  ${BLUE}[4]${NC} Update voice-agent only"
    echo -e "  ${BLUE}[5]${NC} Check status only (no updates)"
    echo -e "  ${BLUE}[0]${NC} Exit"
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$UPDATES_AVAILABLE" = true ]; then
        echo -e "${YELLOW}  ${WARN} Updates are available!${NC}"
        echo ""
    fi

    read -p "Enter your choice (0-5): " choice
    echo ""
    return $choice
}

# Backup .env file
backup_env() {
    if [ -f ".env" ]; then
        local backup_file=".env.backup.$(date +%Y%m%d_%H%M%S)"
        cp .env "$backup_file"
        log_info "Backed up .env to $backup_file"
        echo ""
    fi
}

# Main execution
main() {
    show_banner

    # Check if repositories exist
    if [ ! -d "frontend" ] && [ ! -d "backend" ] && [ ! -d "voice-agent" ]; then
        log_error "No repositories found. Run ./start-staging.sh first to clone repositories."
        exit 1
    fi

    # Backup .env before any changes
    backup_env

    while true; do
        show_status
        show_menu
        choice=$?

        case $choice in
            1)
                log_info "Updating all repositories..."
                echo ""

                update_repo "Frontend" "frontend"
                if [ $? -eq 0 ]; then
                    restart_service "frontend"
                fi

                update_repo "Backend" "backend"
                if [ $? -eq 0 ]; then
                    restart_service "backend"
                fi

                update_repo "Voice Agent" "voice-agent"
                if [ $? -eq 0 ]; then
                    restart_service "voice-agent"
                fi

                log_success "All updates complete!"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                update_repo "Frontend" "frontend"
                if [ $? -eq 0 ]; then
                    restart_service "frontend"
                fi
                read -p "Press Enter to continue..."
                ;;
            3)
                update_repo "Backend" "backend"
                if [ $? -eq 0 ]; then
                    restart_service "backend"
                fi
                read -p "Press Enter to continue..."
                ;;
            4)
                update_repo "Voice Agent" "voice-agent"
                if [ $? -eq 0 ]; then
                    restart_service "voice-agent"
                fi
                read -p "Press Enter to continue..."
                ;;
            5)
                log_info "Status check only - no updates performed"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            0)
                echo ""
                echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
                echo -e "${GREEN}║  ${BOLD}Thanks for using the update manager!${NC}${GREEN}  ║${NC}"
                echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
                echo ""
                log_info "Update session ended"
                exit 0
                ;;
            *)
                log_error "Invalid choice. Please enter 0-5."
                sleep 2
                ;;
        esac
    done
}

# Run main
main
