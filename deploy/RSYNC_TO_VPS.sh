#!/bin/bash
# ============================================================
# Rsync Files from Local Workspace to VPS
# ============================================================
# Purpose: Sync null-safety fixes to production VPS
# Usage: ./RSYNC_TO_VPS.sh <VPS_IP_OR_HOSTNAME>
# Example: ./RSYNC_TO_VPS.sh 167.99.123.45
# ============================================================

set -e

# Check if VPS address provided
if [ -z "$1" ]; then
    echo "Error: VPS address required"
    echo "Usage: $0 <VPS_IP_OR_HOSTNAME>"
    echo "Example: $0 167.99.123.45"
    exit 1
fi

VPS_HOST="$1"
VPS_USER="root"
VPS_BASE="/var/www/tagxi/appsrc/Main-File-August-20"

# ANSI Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}Syncing Hayya Ride fixes to VPS${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo "VPS Host: $VPS_USER@$VPS_HOST"
echo "Target: $VPS_BASE"
echo ""

# Test SSH connection
echo -e "${YELLOW}Testing SSH connection...${NC}"
if ssh -o ConnectTimeout=5 "$VPS_USER@$VPS_HOST" "echo 'Connection successful'" > /dev/null 2>&1; then
    echo -e "${GREEN}? SSH connection successful${NC}"
else
    echo -e "${RED}? Cannot connect to VPS${NC}"
    echo "Please check:"
    echo "  1. VPS IP/hostname is correct"
    echo "  2. SSH key is configured"
    echo "  3. VPS is running and accessible"
    exit 1
fi

echo ""

# Create directories on VPS
echo -e "${YELLOW}Creating directories on VPS...${NC}"
ssh "$VPS_USER@$VPS_HOST" "mkdir -p $VPS_BASE/flutter_user/flutter_user/lib/utils"
ssh "$VPS_USER@$VPS_HOST" "mkdir -p $VPS_BASE/flutter_driver/flutter_driver/lib/utils"
echo -e "${GREEN}? Directories created${NC}"

echo ""

# Sync Rider files
echo -e "${YELLOW}Syncing Rider app files...${NC}"
rsync -avz --progress \
    /workspace/vps_sync/rider/lib/utils/safe.dart \
    "$VPS_USER@$VPS_HOST:$VPS_BASE/flutter_user/flutter_user/lib/utils/"

rsync -avz --progress \
    /workspace/vps_sync/rider/lib/functions/functions.dart \
    "$VPS_USER@$VPS_HOST:$VPS_BASE/flutter_user/flutter_user/lib/functions/"

echo -e "${GREEN}? Rider files synced${NC}"

echo ""

# Sync Driver files
echo -e "${YELLOW}Syncing Driver app files...${NC}"
rsync -avz --progress \
    /workspace/vps_sync/driver/lib/utils/safe.dart \
    "$VPS_USER@$VPS_HOST:$VPS_BASE/flutter_driver/flutter_driver/lib/utils/"

rsync -avz --progress \
    /workspace/vps_sync/driver/lib/functions/functions.dart \
    "$VPS_USER@$VPS_HOST:$VPS_BASE/flutter_driver/flutter_driver/lib/functions/"

echo -e "${GREEN}? Driver files synced${NC}"

echo ""

# Sync deployment script
echo -e "${YELLOW}Syncing deployment script...${NC}"
rsync -avz --progress \
    /workspace/deploy/VPS_DEPLOYMENT_COMMANDS.sh \
    "$VPS_USER@$VPS_HOST:/tmp/"

ssh "$VPS_USER@$VPS_HOST" "chmod +x /tmp/VPS_DEPLOYMENT_COMMANDS.sh"
echo -e "${GREEN}? Deployment script synced${NC}"

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}? All files synced successfully!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. SSH into VPS:"
echo "   ssh $VPS_USER@$VPS_HOST"
echo ""
echo "2. Run deployment script:"
echo "   /tmp/VPS_DEPLOYMENT_COMMANDS.sh"
echo ""
echo "3. Download APKs from:"
echo "   - Rider: $VPS_BASE/flutter_user/flutter_user/builds/"
echo "   - Driver: $VPS_BASE/flutter_driver/flutter_driver/builds/"
echo ""
echo -e "${BLUE}For detailed instructions, see: /workspace/deploy/DEPLOYMENT_MANIFEST.md${NC}"
echo ""
