#!/bin/bash
# Manual end-to-end smoke test against a running backend, no Xcode required.
# Usage: ./scripts/smoke-test.sh   (run from the Backend/ directory, or anywhere)
set -e

BASE="http://127.0.0.1:3000/v1"
DEVICE_ID=$(python3 -c "import uuid; print(uuid.uuid4())")
MUT() { python3 -c "import uuid; print(uuid.uuid4())"; }

echo "== health =="
curl -sf http://127.0.0.1:3000/health && echo

echo "== 1. anonymous auth =="
AUTH=$(curl -sf -X POST "$BASE/auth/anonymous" -H 'Content-Type: application/json' \
  -d "{\"deviceID\":\"$DEVICE_ID\"}")
echo "$AUTH"
TOKEN=$(echo "$AUTH" | python3 -c "import sys,json;print(json.load(sys.stdin)['accessToken'])")
AUTH_HEADER="Authorization: Bearer $TOKEN"

echo "== 2. onboarding =="
curl -sf -o /dev/null -w "HTTP %{http_code}\n" -X POST "$BASE/onboarding" -H "$AUTH_HEADER" -H 'Content-Type: application/json' -d '{
  "name": "Maya", "age": 29, "primaryGoals": ["focus","stress_relief"],
  "assessmentAnswers":[3,4,5,2,4], "connectedWearables":["apple_watch"],
  "initialScores":{"overall":72,"cognitive":80,"biometric":65,"mood":71}
}'

echo "== 3. dashboard =="
curl -sf "$BASE/dashboard" -H "$AUTH_HEADER"; echo

echo "== 4. log mood =="
curl -sf -o /dev/null -w "HTTP %{http_code}\n" -X POST "$BASE/moods" -H "$AUTH_HEADER" -H 'Content-Type: application/json' \
  -d "{\"mood\":4,\"occurredAt\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"clientMutationID\":\"$(MUT)\"}"

echo "== 5. today's plan =="
PLAN=$(curl -sf "$BASE/plans/today" -H "$AUTH_HEADER")
echo "$PLAN"
EX_ID=$(echo "$PLAN" | python3 -c "import sys,json;print(json.load(sys.stdin)[0]['id'])")

echo "== 6. complete exercise =="
curl -sf -o /dev/null -w "HTTP %{http_code}\n" -X POST "$BASE/exercises/$EX_ID/complete" -H "$AUTH_HEADER" -H 'Content-Type: application/json' \
  -d "{\"performance\":0.86,\"completedAt\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"clientMutationID\":\"$(MUT)\"}"

echo "== 7. coach: send message =="
curl -sf -X POST "$BASE/coach/messages" -H "$AUTH_HEADER" -H 'Content-Type: application/json' \
  -d "{\"content\":\"I need help focusing\",\"persona\":\"zen_monk\",\"clientMutationID\":\"$(MUT)\"}"; echo

echo "== 8. coach: history =="
curl -sf "$BASE/coach/messages" -H "$AUTH_HEADER"; echo

echo "== 9. analytics: scores (week) =="
curl -sf "$BASE/analytics/scores?period=week" -H "$AUTH_HEADER"; echo

echo "== 10. profile =="
curl -sf "$BASE/me" -H "$AUTH_HEADER"; echo

echo "== 11. achievements =="
curl -sf "$BASE/me/achievements" -H "$AUTH_HEADER"; echo

echo "== 12. leaderboard =="
curl -sf "$BASE/leaderboard?limit=3" -H "$AUTH_HEADER"; echo

echo
echo "All requests succeeded."
