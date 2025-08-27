#!/usr/bin/env sh
set -eu

# Required tools
apk --no-cache add curl jq >/dev/null

BASE="http://app:9515"

echo "Waiting for ChromeDriver to be ready..."
for i in $(seq 1 30); do
  if curl -sf "${BASE}/status" | jq -e '.value.ready == true' >/dev/null 2>&1; then
    echo "ChromeDriver ready."
    break
  fi
  sleep 1
  [ "$i" -eq 30 ] && { echo "Timeout waiting for /status"; exit 1; }
done

echo "Creating WebDriver session..."
CREATE_PAYLOAD='{
  "capabilities": {
    "firstMatch": [{
      "browserName": "chrome",
      "goog:chromeOptions": {
        "args": ["--headless=new","--no-sandbox","--disable-dev-shm-usage"]
      }
    }]
  }
}'
RESP="$(curl -sf -H 'Content-Type: application/json' -d "${CREATE_PAYLOAD}" "${BASE}/session")"
SESSION_ID="$(echo "$RESP" | jq -r '.value.sessionId')"

if [ -z "${SESSION_ID}" ] || [ "${SESSION_ID}" = "null" ]; then
  echo "No sessionId received. Response:"
  echo "$RESP"
  exit 1
fi
echo "Session created: ${SESSION_ID}"

echo "Navigating to https://example.com ..."
NAV_PAYLOAD='{"url":"https://example.com/"}'
curl -sf -H 'Content-Type: application/json' -d "${NAV_PAYLOAD}" "${BASE}/session/${SESSION_ID}/url" >/dev/null

echo "Reading page title..."
TITLE="$(curl -sf "${BASE}/session/${SESSION_ID}/title" | jq -r '.value')"
echo "Title: ${TITLE}"

if [ "${TITLE}" != "Example Domain" ]; then
  echo "Unexpected title"
  exit 1
fi

echo "Closing session..."
curl -sf -X DELETE "${BASE}/session/${SESSION_ID}" >/dev/null || true

echo "OK: Smoke test completed."
