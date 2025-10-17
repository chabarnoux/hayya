#!/usr/bin/env bash
set -euo pipefail

APP_PATH=${1:-}
if [[ -z "$APP_PATH" ]]; then
  echo "Usage: $0 /path/to/laravel/app" >&2
  exit 1
fi

cd "$APP_PATH"
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
