#!/bin/bash

################################################################################
#                   SimsBuddy Staging - Stop Services                          #
#                      Gracefully stop all services                            #
################################################################################

# Change to the script's directory
cd "$(dirname "$0")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                               ║${NC}"
echo -e "${CYAN}║       ${BOLD}Stopping Staging Services${NC}${CYAN}            ║${NC}"
echo -e "${CYAN}║                                               ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}🛑 Stopping all services...${NC}"
echo ""

docker-compose -f docker-compose.staging.yml down

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ All services stopped successfully!${NC}"
    echo ""
    echo -e "${CYAN}📝 Service status:${NC}"
    echo -e "  • Frontend (5173)    - Stopped"
    echo -e "  • Backend (3000)     - Stopped"
    echo -e "  • Voice Agent (8000) - Stopped"
    echo -e "  • Redis (6379)       - Stopped"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}💡 To start again:${NC}"
    echo -e "   ${BOLD}./start-staging.sh${NC}"
    echo ""
    echo -e "${CYAN}💡 To remove all data (clean slate):${NC}"
    echo -e "   ${BOLD}docker-compose -f docker-compose.staging.yml down -v${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Error stopping services${NC}"
    echo ""
    echo -e "${YELLOW}Try manually:${NC}"
    echo -e "  ${BOLD}docker-compose -f docker-compose.staging.yml down${NC}"
    echo ""
    exit 1
fi
