#!/usr/bin/env bash
set -euo pipefail

# Quick reachability checks for admin auth routes
BASE_URL=${1:-"https://admin.hayyaride.com"}

for path in /login /dashboard /logout; do
  code=$(curl -k -s -o /dev/null -w "%{http_code}" -L "${BASE_URL}${path}")
  echo "${BASE_URL}${path} -> HTTP ${code}"
done
