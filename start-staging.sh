#!/bin/bash

################################################################################
#                   SimsBuddy Staging Environment Setup                       #
#                            User-Friendly Version                             #
################################################################################

# Change to the script's directory
cd "$(dirname "$0")"
SCRIPT_DIR=$(pwd)

# Create logs directory
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/staging_$(date +%Y%m%d_%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Emojis
CHECK="✅"
CROSS="❌"
WARN="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
CLOCK="⏱️"
PACKAGE="📦"
FIRE="🔥"
STAR="⭐"

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

log_step() {
    local step=$1
    local total=$2
    local message="$3"
    log "${BOLD}${BLUE}[Step $step/$total]${NC} $message"
}

# Welcome banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║           ${BOLD}SimsBuddy Staging Environment Setup${NC}${CYAN}              ║"
    echo "║                                                                ║"
    echo "║                  Welcome! Let's get started ${ROCKET}                 ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    log_info "Starting setup at $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "Log file: $LOG_FILE"
    echo ""
}

# Pre-flight checks
preflight_check() {
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  ${GEAR} PRE-FLIGHT CHECKS${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    local all_checks_passed=true

    # Check 1: Git
    echo -ne "  ${CLOCK} Checking Git installation... "
    if command -v git &> /dev/null; then
        echo -e "${GREEN}${CHECK} Installed$(git --version | head -1)${NC}"
    else
        echo -e "${RED}${CROSS} Not found${NC}"
        log_error "Git is not installed. Please install Git first."
        echo ""
        echo -e "${YELLOW}  📥 Download Git:${NC}"
        echo -e "     Mac: https://git-scm.com/download/mac"
        echo -e "     Windows: https://git-scm.com/download/win"
        echo -e "     Linux: sudo apt-get install git"
        echo ""
        all_checks_passed=false
    fi

    # Check 2: Docker
    echo -ne "  ${CLOCK} Checking Docker installation... "
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}${CHECK} Installed${NC}"
    else
        echo -e "${RED}${CROSS} Not found${NC}"
        log_error "Docker is not installed. Please install Docker Desktop first."
        echo ""
        echo -e "${YELLOW}  📥 Download Docker Desktop:${NC}"
        echo -e "     https://www.docker.com/products/docker-desktop/"
        echo ""
        all_checks_passed=false
    fi

    # Check 3: Docker Running
    echo -ne "  ${CLOCK} Checking Docker Desktop status... "
    if docker info > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} Running${NC}"
    else
        echo -e "${RED}${CROSS} Not running${NC}"
        log_error "Docker Desktop is not running!"
        echo ""
        echo -e "${YELLOW}  🔧 How to fix:${NC}"
        echo -e "     1. Open Docker Desktop application"
        echo -e "     2. Wait for 'Docker Desktop is running' message"
        echo -e "     3. Run this script again"
        echo ""
        all_checks_passed=false
    fi

    # Check 4: Ports availability
    echo -ne "  ${CLOCK} Checking required ports... "
    local ports_in_use=()
    for port in 3000 5173 6379 8000; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            ports_in_use+=($port)
        fi
    done

    if [ ${#ports_in_use[@]} -eq 0 ]; then
        echo -e "${GREEN}${CHECK} All ports available${NC}"
    else
        echo -e "${YELLOW}${WARN} Ports in use: ${ports_in_use[*]}${NC}"
        log_warning "Some ports are already in use: ${ports_in_use[*]}"
        echo ""
        echo -e "${YELLOW}  🔧 Ports in use: ${ports_in_use[*]}${NC}"
        echo -e "     These services might conflict. Do you want to continue? (y/n)"
        read -p "     " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            all_checks_passed=false
        fi
    fi

    # Check 5: .env file
    echo -ne "  ${CLOCK} Checking .env configuration... "
    if [ -f ".env" ]; then
        # Check if .env has required variables
        required_vars=("DATABASE_URL" "LIVEKIT_URL" "GROQ_API_KEY" "ASSEMBLY_API_KEY" "INWORLD_API_KEY")
        missing_vars=()

        for var in "${required_vars[@]}"; do
            if ! grep -q "^$var=" ".env" 2>/dev/null; then
                missing_vars+=("$var")
            fi
        done

        if [ ${#missing_vars[@]} -eq 0 ]; then
            echo -e "${GREEN}${CHECK} Configured${NC}"
        else
            echo -e "${YELLOW}${WARN} Missing variables${NC}"
            log_warning "Missing required variables in .env: ${missing_vars[*]}"
            echo ""
            echo -e "${YELLOW}  🔧 Missing variables: ${missing_vars[*]}${NC}"
            echo -e "     Please add these to your .env file"
            echo -e "     See .env.example for reference"
            echo ""
        fi
    else
        echo -e "${YELLOW}${WARN} Not found${NC}"
        log_warning ".env file not found"
        echo ""
        echo -e "${YELLOW}  🔧 How to fix:${NC}"
        echo -e "     1. Copy the example: cp .env.example .env"
        echo -e "     2. Edit .env and fill in your values"
        echo -e "     3. Run this script again"
        echo ""
        echo -e "  Do you want me to create .env from .env.example now? (y/n)"
        read -p "  " create_env
        if [[ "$create_env" =~ ^[Yy]$ ]]; then
            if [ -f ".env.example" ]; then
                cp .env.example .env
                log_success "Created .env from .env.example"
                echo -e "${YELLOW}  Please edit .env and fill in your values, then run this script again.${NC}"
                all_checks_passed=false
            else
                log_error ".env.example not found"
                all_checks_passed=false
            fi
        else
            all_checks_passed=false
        fi
    fi

    # Check 6: Disk space
    echo -ne "  ${CLOCK} Checking disk space... "
    local available_space
    if [[ "$OSTYPE" == "darwin"* ]]; then
        available_space=$(df -g . | tail -1 | awk '{print $4}')
        if [ "$available_space" -gt 10 ]; then
            echo -e "${GREEN}${CHECK} ${available_space}GB available${NC}"
        else
            echo -e "${YELLOW}${WARN} Only ${available_space}GB available${NC}"
            log_warning "Low disk space: ${available_space}GB"
        fi
    else
        echo -e "${GREEN}${CHECK} Available${NC}"
    fi

    echo ""

    if [ "$all_checks_passed" = true ]; then
        log_success "All pre-flight checks passed!"
        echo ""
        return 0
    else
        log_error "Some pre-flight checks failed. Please fix the issues above."
        echo ""
        exit 1
    fi
}

# Show what will happen
show_plan() {
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  ${INFO} SETUP PLAN${NC}"
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${STAR} Here's what will happen:"
    echo ""
    echo -e "  ${BLUE}1.${NC} Choose Git protocol (HTTPS or SSH)"
    echo -e "  ${BLUE}2.${NC} Download latest staging code (3 repositories)"
    echo -e "  ${BLUE}3.${NC} Build voice-agent Docker image (~2-3 min first time)"
    echo -e "  ${BLUE}4.${NC} Start all services (Redis, Backend, Frontend, Voice-Agent)"
    echo -e "  ${BLUE}5.${NC} Verify everything is running"
    echo ""
    echo -e "  ${CLOCK} ${BOLD}Estimated time:${NC} 3-5 minutes (first run)"
    echo -e "  ${CLOCK} ${BOLD}Subsequent runs:${NC} ~1 minute"
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "Press Enter to continue..."
    echo ""
}

# Git protocol selection
select_git_protocol() {
    log_step 1 5 "Selecting Git Protocol"
    echo ""
    echo -e "${YELLOW}How would you like to connect to GitHub?${NC}"
    echo ""
    echo -e "  ${BLUE}1)${NC} HTTPS ${GREEN}(Recommended - works immediately)${NC}"
    echo -e "  ${BLUE}2)${NC} SSH ${CYAN}(Faster, but requires SSH key setup)${NC}"
    echo ""
    read -p "Enter your choice (1 or 2): " git_choice

    case $git_choice in
        1)
            log_success "Using HTTPS for Git"
            FRONTEND_REPO="https://github.com/omarelmoghazy/simsbuddy.git"
            BACKEND_REPO="https://github.com/MHGanainy/mvp-backend.git"
            VOICE_REPO="https://github.com/MHGanainy/simsbuddy-voice-agent.git"
            ;;
        2)
            if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
                log_warning "No SSH key found"
                echo ""
                echo -e "${YELLOW}SSH key not found. Using HTTPS instead.${NC}"
                echo -e "${INFO} To use SSH in the future, set up an SSH key:"
                echo -e "   https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
                echo ""
                FRONTEND_REPO="https://github.com/omarelmoghazy/simsbuddy.git"
                BACKEND_REPO="https://github.com/MHGanainy/mvp-backend.git"
                VOICE_REPO="https://github.com/MHGanainy/simsbuddy-voice-agent.git"
            else
                log_success "Using SSH for Git"
                FRONTEND_REPO="git@github.com:omarelmoghazy/simsbuddy.git"
                BACKEND_REPO="git@github.com:MHGanainy/mvp-backend.git"
                VOICE_REPO="git@github.com:MHGanainy/simsbuddy-voice-agent.git"
            fi
            ;;
        *)
            log_warning "Invalid choice. Using HTTPS"
            FRONTEND_REPO="https://github.com/omarelmoghazy/simsbuddy.git"
            BACKEND_REPO="https://github.com/MHGanainy/mvp-backend.git"
            VOICE_REPO="https://github.com/MHGanainy/simsbuddy-voice-agent.git"
            ;;
    esac
    echo ""
}

# Setup repository
setup_repository() {
    local repo_name=$1
    local repo_url=$2
    local dir_name=$3

    echo -ne "  ${CLOCK} $repo_name: "

    if [ ! -d "$dir_name" ]; then
        echo -e "${YELLOW}Cloning...${NC}"
        git clone -b staging "$repo_url" "$dir_name" >> "$LOG_FILE" 2>&1

        if [ $? -eq 0 ]; then
            echo -e "  ${CHECK} ${GREEN}Cloned successfully${NC}"
        else
            echo -e "  ${CROSS} ${RED}Clone failed${NC}"
            log_error "Failed to clone $repo_name"
            return 1
        fi
    else
        echo -e "${YELLOW}Updating...${NC}"
        cd "$dir_name"

        # Stash changes
        if ! git diff --quiet || ! git diff --cached --quiet; then
            git stash push -m "Auto-stash $(date +%Y%m%d_%H%M%S)" >> "$LOG_FILE" 2>&1
        fi

        # Checkout and pull
        git checkout staging >> "$LOG_FILE" 2>&1
        git pull origin staging >> "$LOG_FILE" 2>&1

        if [ $? -eq 0 ]; then
            local commit=$(git log -1 --oneline | cut -d' ' -f1)
            echo -e "  ${CHECK} ${GREEN}Updated to $commit${NC}"
        else
            echo -e "  ${CROSS} ${RED}Update failed${NC}"
            log_error "Failed to update $repo_name"
        fi

        cd "$SCRIPT_DIR"
    fi
}

# Download code
download_code() {
    log_step 2 5 "Downloading Code from GitHub"
    echo ""
    echo -e "  ${PACKAGE} Fetching latest staging code..."
    echo ""

    setup_repository "Frontend" "$FRONTEND_REPO" "frontend"
    setup_repository "Backend" "$BACKEND_REPO" "backend"
    setup_repository "Voice Agent" "$VOICE_REPO" "voice-agent"

    echo ""
    log_success "All repositories ready!"
    echo ""
}

# Build and start services
start_services() {
    log_step 3 5 "Building Docker Images"
    echo ""
    echo -e "  ${GEAR} This may take 2-3 minutes on first run..."
    echo -e "  ${INFO} Grab a coffee ${FIRE} - Docker is working hard!"
    echo ""

    docker-compose -f docker-compose.staging.yml build >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        log_success "Docker images built successfully"
    else
        log_error "Docker build failed - check logs"
        return 1
    fi

    echo ""
    log_step 4 5 "Starting All Services"
    echo ""
    echo -e "  ${ROCKET} Starting: Redis, Backend, Frontend, Voice-Agent..."
    echo ""

    docker-compose -f docker-compose.staging.yml up -d >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        log_success "All services started"
    else
        log_error "Failed to start services"
        return 1
    fi

    echo ""
    echo -e "  ${CLOCK} Waiting for services to initialize (30 seconds)..."

    for i in {1..30}; do
        echo -ne "\r  ${CLOCK} Initializing... $i/30 seconds "
        sleep 1
    done
    echo ""
    echo ""
}

# Verify services
verify_services() {
    log_step 5 5 "Verifying Services"
    echo ""

    local all_healthy=true

    # Check Redis
    echo -ne "  ${CLOCK} Redis... "
    if docker exec dev-environment-redis-1 redis-cli ping > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} Running${NC}"
    else
        echo -e "${RED}${CROSS} Not responding${NC}"
        all_healthy=false
    fi

    # Check Backend
    echo -ne "  ${CLOCK} Backend API... "
    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} Running${NC}"
    else
        echo -e "${YELLOW}${WARN} Starting up...${NC}"
    fi

    # Check Frontend
    echo -ne "  ${CLOCK} Frontend... "
    if curl -s -I http://localhost:5173 > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} Running${NC}"
    else
        echo -e "${YELLOW}${WARN} Starting up...${NC}"
    fi

    # Check Voice Agent
    echo -ne "  ${CLOCK} Voice Agent... "
    if curl -s http://localhost:8000/ > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} Running${NC}"
    else
        echo -e "${YELLOW}${WARN} Starting up...${NC}"
    fi

    echo ""

    if [ "$all_healthy" = true ]; then
        return 0
    else
        log_warning "Some services are still starting up"
        return 1
    fi
}

# Success message
show_success() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                ║${NC}"
    echo -e "${GREEN}║               ${BOLD}${CHECK} ALL SERVICES RUNNING! ${CHECK}${NC}${GREEN}                      ║${NC}"
    echo -e "${GREEN}║                                                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}🌐 Access your services:${NC}"
    echo ""
    echo -e "  ${BLUE}Frontend:${NC}    ${BOLD}http://localhost:5173${NC}"
    echo -e "               ${CYAN}(Main application - start here!)${NC}"
    echo ""
    echo -e "  ${BLUE}Backend API:${NC} ${BOLD}http://localhost:3000${NC}"
    echo -e "               ${CYAN}(Health check: http://localhost:3000/api/health)${NC}"
    echo ""
    echo -e "  ${BLUE}Voice Agent:${NC} ${BOLD}http://localhost:8000${NC}"
    echo -e "               ${CYAN}(AI voice conversation system)${NC}"
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}${YELLOW}📝 What's running:${NC}"
    echo ""
    echo -e "  ${CHECK} Frontend - React with Vite (hot reload enabled)"
    echo -e "  ${CHECK} Backend - Fastify API server"
    echo -e "  ${CHECK} Voice Agent - AI conversation system"
    echo -e "  ${CHECK} Redis - Session storage"
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}💡 Tips:${NC}"
    echo ""
    echo -e "  ${STAR} Code changes will auto-reload (hot reload is enabled)"
    echo -e "  ${STAR} Logs are saved to: ${LOG_FILE}"
    echo -e "  ${STAR} View logs: ${YELLOW}docker-compose -f docker-compose.staging.yml logs -f${NC}"
    echo ""
    echo -e "${BOLD}${RED}🛑 To stop all services:${NC}"
    echo -e "  Press ${BOLD}Ctrl+C${NC} in this terminal"
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}${GREEN}Happy coding! ${ROCKET}${NC}"
    echo ""
}

# Main execution
main() {
    show_banner
    preflight_check
    show_plan
    select_git_protocol
    download_code
    start_services
    verify_services
    show_success

    echo -e "${CYAN}Starting log stream (Press Ctrl+C to exit)...${NC}"
    echo ""
    sleep 2
    docker-compose -f docker-compose.staging.yml logs -f
}

# Run main
main
