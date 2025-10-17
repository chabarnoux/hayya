#!/usr/bin/env bash
set -euo pipefail

# Usage: ./update_env.sh /var/www/tagxi/appsrc/Main-File-August-20/Admin-Panel-Aug-20-2025 \
#   GOOGLE_MAPS_API_KEY=xxx GOOGLE_MAPS_SERVER_KEY=yyy FCM_SERVER_KEY=zzz FIREBASE_PROJECT_ID=aaa FIREBASE_WEB_API_KEY=bbb

APP_PATH=${1:-}
shift || true

if [[ -z "$APP_PATH" ]]; then
  echo "ERROR: Provide Laravel app path as first argument" >&2
  exit 1
fi

ENV_FILE="$APP_PATH/.env"
BACKUP_FILE="$ENV_FILE.$(date +%Y%m%d%H%M%S).bak"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env not found at $ENV_FILE" >&2
  exit 1
fi

cp "$ENV_FILE" "$BACKUP_FILE"
echo "Backed up .env to $BACKUP_FILE"

# Build key=value map from remaining args
for kv in "$@"; do
  key="${kv%%=*}"
  val="${kv#*=}"
  if grep -qE "^${key}=" "$ENV_FILE"; then
    sed -i "/^${key}=.*/c\${key}=${val}" "$ENV_FILE"
  else
    echo "${key}=${val}" >> "$ENV_FILE"
  fi
  echo "Set $key"
done

echo "Done updating .env"
