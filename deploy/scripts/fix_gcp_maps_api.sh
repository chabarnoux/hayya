#!/bin/bash
# Script to fix Google Maps API key authorization for Hayya Admin Panel
# This script uses gcloud CLI to update API key restrictions

set -e

PROJECT_ID="hayyaride"
BROWSER_KEY_NAME="Browser"  # Update this with actual key name from GCP console

echo "==================================="
echo "Hayya Maps API Key Fixer"
echo "==================================="
echo ""
echo "This script will:"
echo "1. Update Browser API key with proper referrer restrictions"
echo "2. Ensure required APIs are enabled"
echo ""

# Set project
echo "Setting GCP project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo ""
echo "Enabling required Google Maps APIs..."
gcloud services enable \
  maps-backend.googleapis.com \
  places-backend.googleapis.com \
  geocoding-backend.googleapis.com \
  directions-backend.googleapis.com \
  distance-matrix-backend.googleapis.com \
  geolocation.googleapis.com

echo ""
echo "? APIs enabled successfully"

# Instructions for manual key update
echo ""
echo "==================================="
echo "MANUAL STEPS REQUIRED"
echo "==================================="
echo ""
echo "Please go to Google Cloud Console and update the Browser API key:"
echo ""
echo "1. Navigate to: https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
echo ""
echo "2. Find the 'Browser' API key and click Edit"
echo ""
echo "3. Under 'Application restrictions', select 'HTTP referrers (web sites)'"
echo ""
echo "4. Add these referrers:"
echo "   - https://admin.hayyaride.com/*"
echo "   - http://admin.hayyaride.com/*"
echo "   - https://*.hayyaride.com/*"
echo "   - http://*.hayyaride.com/*"
echo "   - https://hayyaride.com/*"
echo "   - http://hayyaride.com/*"
echo ""
echo "5. Under 'API restrictions', select 'Restrict key' and enable:"
echo "   - Maps JavaScript API"
echo "   - Places API"
echo "   - Geocoding API"
echo "   - Directions API"
echo "   - Distance Matrix API"
echo ""
echo "6. Click SAVE"
echo ""
echo "After updating the key, run: bash deploy/scripts/clear_admin_cache.sh"
echo ""
