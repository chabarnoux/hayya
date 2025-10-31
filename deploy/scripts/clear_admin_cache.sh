#!/bin/bash
# Script to clear Laravel cache after Maps API key update
# Run this on the VPS after updating Google Maps API key

set -e

ADMIN_PATH="/var/www/tagxi/appsrc/Main-File-August-20/Admin-Panel-Aug-20-2025"

echo "==================================="
echo "Clearing Laravel Cache"
echo "==================================="
echo ""

if [ ! -d "$ADMIN_PATH" ]; then
    echo "ERROR: Admin panel directory not found at $ADMIN_PATH"
    echo "Please update ADMIN_PATH in this script"
    exit 1
fi

cd "$ADMIN_PATH"

echo "Clearing configuration cache..."
php artisan config:clear

echo "Clearing application cache..."
php artisan cache:clear

echo "Clearing optimized files..."
php artisan optimize:clear

echo "Clearing view cache..."
php artisan view:clear

echo "Clearing route cache..."
php artisan route:clear

echo ""
echo "? All caches cleared successfully!"
echo ""
echo "Please test the admin panel maps at:"
echo "  - Geofencing page"
echo "  - Dispatch page"
echo "  - Web Booking page"
echo ""
