#!/usr/bin/env bash
set -euo pipefail

# Usage example:
#   FIREBASE_PROJECT_ID=hayyaride \
#   DEVICE_TOKEN=your_device_token \
#   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
#   ./test_fcm_v1.sh
# Optional envs: TITLE, BODY

FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-}
DEVICE_TOKEN=${DEVICE_TOKEN:-}
TITLE=${TITLE:-"Hayya Ride Test"}
BODY=${BODY:-"Hello from Laravel v1"}

if [[ -z "$FIREBASE_PROJECT_ID" || -z "$DEVICE_TOKEN" ]]; then
  echo "ERROR: Provide FIREBASE_PROJECT_ID and DEVICE_TOKEN env vars" >&2
  exit 1
fi

if ! command -v gcloud >/dev/null 2>&1; then
  echo "ERROR: gcloud CLI is required for this script (uses ADC)." >&2
  echo "Install: https://cloud.google.com/sdk/docs/install" >&2
  echo "Then set GOOGLE_APPLICATION_CREDENTIALS to a service account JSON with FCM scope." >&2
  exit 1
fi

# Use Application Default Credentials to get an access token
ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
if [[ -z "${ACCESS_TOKEN:-}" ]]; then
  echo "ERROR: Failed to obtain access token via ADC. Ensure GOOGLE_APPLICATION_CREDENTIALS is set." >&2
  exit 1
fi

read -r -d '' JSON_PAYLOAD <<EOF
{
  "message": {
    "token": "${DEVICE_TOKEN}",
    "notification": { "title": "${TITLE}", "body": "${BODY}" },
    "data": { "type": "test" }
  }
}
EOF

set -x
curl -sS -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json; UTF-8" \
  -d "${JSON_PAYLOAD}" \
  "https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send"
set +x

echo
