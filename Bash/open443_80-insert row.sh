#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to handle a port in OUTPUT chain
handle_port() {
    local port=$1

    if iptables -C OUTPUT -p tcp --dport $port -j ACCEPT 2>/dev/null; then
        echo -e "${GREEN}Closing port $port in OUTPUT chain${NC}"
        iptables -D OUTPUT -p tcp --dport $port -j ACCEPT
    else
        echo -e "${RED}Opening port $port in OUTPUT chain${NC}"
        iptables -I OUTPUT 127 -p tcp --dport $port -j ACCEPT
    fi
}

# Handle port 80 (HTTP)
handle_port 80

# Handle port 443 (HTTPS)
handle_port 443

echo "Script has completed running."
