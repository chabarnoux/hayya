#!/bin/bash
# ============================================================
# VPS Deployment Commands - Run these on your VPS
# ============================================================
# Server: /var/www/tagxi
# Date: 2025-10-31
# Purpose: Deploy null-safety fixes and rebuild apps
# ============================================================

set -e

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}Hayya Ride - VPS Deployment Script${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Base paths
VPS_BASE="/var/www/tagxi/appsrc/Main-File-August-20"
ADMIN_PATH="$VPS_BASE/Admin-Panel-Aug-20-2025"
RIDER_PATH="$VPS_BASE/flutter_user/flutter_user"
DRIVER_PATH="$VPS_BASE/flutter_driver/flutter_driver"

# ============================================================
# STEP 1: Clear Laravel Admin Cache
# ============================================================
echo -e "${YELLOW}[Step 1/4] Clearing Laravel Admin Cache...${NC}"
echo ""

if [ -d "$ADMIN_PATH" ]; then
    cd "$ADMIN_PATH"
    
    echo "Running Laravel cache clearing commands..."
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    php artisan view:clear
    php artisan optimize:clear
    
    echo -e "${GREEN}? Admin cache cleared successfully${NC}"
else
    echo -e "${RED}? Admin path not found: $ADMIN_PATH${NC}"
    exit 1
fi

echo ""

# ============================================================
# STEP 2: Build Rider App
# ============================================================
echo -e "${YELLOW}[Step 2/4] Building Rider App...${NC}"
echo ""

if [ -d "$RIDER_PATH" ]; then
    cd "$RIDER_PATH"
    
    echo "Cleaning previous build..."
    flutter clean
    
    echo "Getting dependencies..."
    flutter pub get
    
    echo "Building APK (debug)..."
    flutter build apk --debug
    
    # Copy to builds directory
    mkdir -p builds
    cp build/app/outputs/flutter-apk/app-debug.apk "builds/rider-debug-$(date +%Y%m%d-%H%M%S).apk"
    cp build/app/outputs/flutter-apk/app-debug.apk builds/rider-debug-latest.apk
    
    echo -e "${GREEN}? Rider APK built successfully${NC}"
    echo -e "Location: $RIDER_PATH/builds/rider-debug-latest.apk"
else
    echo -e "${RED}? Rider path not found: $RIDER_PATH${NC}"
    exit 1
fi

echo ""

# ============================================================
# STEP 3: Build Driver App
# ============================================================
echo -e "${YELLOW}[Step 3/4] Building Driver App...${NC}"
echo ""

if [ -d "$DRIVER_PATH" ]; then
    cd "$DRIVER_PATH"
    
    echo "Cleaning previous build..."
    flutter clean
    
    echo "Getting dependencies..."
    flutter pub get
    
    echo "Building APK (debug)..."
    flutter build apk --debug
    
    # Copy to builds directory
    mkdir -p builds
    cp build/app/outputs/flutter-apk/app-debug.apk "builds/driver-debug-$(date +%Y%m%d-%H%M%S).apk"
    cp build/app/outputs/flutter-apk/app-debug.apk builds/driver-debug-latest.apk
    
    echo -e "${GREEN}? Driver APK built successfully${NC}"
    echo -e "Location: $DRIVER_PATH/builds/driver-debug-latest.apk"
else
    echo -e "${RED}? Driver path not found: $DRIVER_PATH${NC}"
    exit 1
fi

echo ""

# ============================================================
# STEP 4: Verify Deployment
# ============================================================
echo -e "${YELLOW}[Step 4/4] Verifying Deployment...${NC}"
echo ""

# Check if files exist
FILES_TO_CHECK=(
    "$RIDER_PATH/lib/utils/safe.dart"
    "$RIDER_PATH/lib/functions/functions.dart"
    "$DRIVER_PATH/lib/utils/safe.dart"
    "$DRIVER_PATH/lib/functions/functions.dart"
)

ALL_GOOD=true
for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}?${NC} Found: $file"
    else
        echo -e "${RED}?${NC} Missing: $file"
        ALL_GOOD=false
    fi
done

echo ""

if [ "$ALL_GOOD" = true ]; then
    echo -e "${GREEN}============================================================${NC}"
    echo -e "${GREEN}? Deployment completed successfully!${NC}"
    echo -e "${GREEN}============================================================${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Download APKs from:"
    echo "   - Rider: $RIDER_PATH/builds/rider-debug-latest.apk"
    echo "   - Driver: $DRIVER_PATH/builds/driver-debug-latest.apk"
    echo ""
    echo "2. Test the apps:"
    echo "   - Rider: OTP login should work without red screen crashes"
    echo "   - Driver: Should not crash on login (may need category setup)"
    echo ""
    echo "3. Test admin maps at: https://admin.hayyaride.com"
    echo "   - Verify Google Maps load correctly"
    echo "   - Check geofencing, dispatch, and web booking pages"
    echo ""
else
    echo -e "${RED}============================================================${NC}"
    echo -e "${RED}? Deployment completed with warnings${NC}"
    echo -e "${RED}============================================================${NC}"
    echo ""
    echo "Some files are missing. Please copy them from the workspace:"
    echo "  rsync -avz /workspace/vps_sync/rider/lib/utils/ root@YOUR_VPS:$RIDER_PATH/lib/utils/"
    echo "  rsync -avz /workspace/vps_sync/rider/lib/functions/ root@YOUR_VPS:$RIDER_PATH/lib/functions/"
    echo "  rsync -avz /workspace/vps_sync/driver/lib/utils/ root@YOUR_VPS:$DRIVER_PATH/lib/utils/"
    echo "  rsync -avz /workspace/vps_sync/driver/lib/functions/ root@YOUR_VPS:$DRIVER_PATH/lib/functions/"
    echo ""
fi

echo ""
echo -e "${BLUE}Deployment log: /var/log/hayya_deployment_$(date +%Y%m%d-%H%M%S).log${NC}"
