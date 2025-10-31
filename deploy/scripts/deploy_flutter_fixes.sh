#!/bin/bash
# Script to deploy null-safety fixes to Flutter apps on VPS
# This syncs the fixed code from local workspace to VPS

set -e

VPS_BASE="/var/www/tagxi/appsrc/Main-File-August-20"
RIDER_PATH="$VPS_BASE/flutter_user/flutter_user"
DRIVER_PATH="$VPS_BASE/flutter_driver/flutter_driver"

echo "==================================="
echo "Deploying Flutter Null-Safety Fixes"
echo "==================================="
echo ""

# Check if we're running on VPS or need to copy files
if [ -d "$RIDER_PATH" ]; then
    echo "Running on VPS - copying files directly..."
    
    # Copy Rider fixes
    echo ""
    echo "Deploying Rider app fixes..."
    cp -v /workspace/rider/lib/utils/safe.dart "$RIDER_PATH/lib/utils/safe.dart"
    cp -v /workspace/rider/lib/functions/functions.dart "$RIDER_PATH/lib/functions/functions.dart"
    
    # Copy Driver fixes
    echo ""
    echo "Deploying Driver app fixes..."
    cp -v /workspace/driver/lib/utils/safe.dart "$DRIVER_PATH/lib/utils/safe.dart"
    cp -v /workspace/driver/lib/functions/functions.dart "$DRIVER_PATH/lib/functions/functions.dart"
    
    echo ""
    echo "? Files copied successfully!"
    
else
    echo "Not running on VPS. Files are ready at:"
    echo "  - /workspace/rider/lib/utils/safe.dart"
    echo "  - /workspace/rider/lib/functions/functions.dart"
    echo "  - /workspace/driver/lib/utils/safe.dart"
    echo "  - /workspace/driver/lib/functions/functions.dart"
    echo ""
    echo "Please copy these files to VPS manually or use rsync:"
    echo ""
    echo "rsync -avz /workspace/rider/lib/utils/safe.dart root@YOUR_VPS:$RIDER_PATH/lib/utils/"
    echo "rsync -avz /workspace/rider/lib/functions/functions.dart root@YOUR_VPS:$RIDER_PATH/lib/functions/"
    echo "rsync -avz /workspace/driver/lib/utils/safe.dart root@YOUR_VPS:$DRIVER_PATH/lib/utils/"
    echo "rsync -avz /workspace/driver/lib/functions/functions.dart root@YOUR_VPS:$DRIVER_PATH/lib/functions/"
    echo ""
fi

echo ""
echo "==================================="
echo "Next Steps"
echo "==================================="
echo ""
echo "1. Build Rider APK:"
echo "   cd $RIDER_PATH"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter build apk --debug"
echo ""
echo "2. Build Driver APK:"
echo "   cd $DRIVER_PATH"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter build apk --debug"
echo ""
echo "3. Test the apps:"
echo "   - Rider: OTP login should work without red screen"
echo "   - Driver: Should not crash on login"
echo ""
