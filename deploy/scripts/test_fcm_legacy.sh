#!/usr/bin/env bash
set -euo pipefail

# Usage example:
#   FCM_SERVER_KEY=xxx DEVICE_TOKEN=yyy ./test_fcm_legacy.sh
# Optional envs: TITLE, BODY

FCM_SERVER_KEY=${FCM_SERVER_KEY:-}
DEVICE_TOKEN=${DEVICE_TOKEN:-}
TITLE=${TITLE:-"Hayya Ride Test"}
BODY=${BODY:-"Hello from Laravel"}

if [[ -z "$FCM_SERVER_KEY" || -z "$DEVICE_TOKEN" ]]; then
  echo "ERROR: Provide FCM_SERVER_KEY and DEVICE_TOKEN env vars" >&2
  exit 1
fi

JSON_PAYLOAD=$(printf '{"to":"%s","notification":{"title":"%s","body":"%s"},"data":{"type":"test"}}' \
  "$DEVICE_TOKEN" "$TITLE" "$BODY")

set -x
curl -sS -X POST \
  -H "Authorization: key=$FCM_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  https://fcm.googleapis.com/fcm/send
set +x

echo
