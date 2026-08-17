#!/usr/bin/env bash
#
# Smoke test for the Customer (Clients) module against a RUNNING PMS.API.
#
# Requires:  bash + curl (Git Bash on Windows works). JSON is parsed with
#            python if available, otherwise jq, otherwise sed.
#
# Usage:
#   ./scripts/smoke-test-customers.sh                 # default http://localhost:5194
#   ./scripts/smoke-test-customers.sh http://localhost:8080
#
# Env overrides:
#   SMOKE_EMAIL / SMOKE_PASSWORD   login credentials (default: admin demo login)
#
# Exit code 0 = every check passed, 1 = at least one check failed.

set -u

BASE_URL="${1:-http://localhost:5194}"
EMAIL="${SMOKE_EMAIL:-dhanshree@acme.co}"
PASSWORD="${SMOKE_PASSWORD:-Password@123}"

PASS=0
FAIL=0

log()  { printf '%s\n' "$*"; }
pass() { log "  PASS  $1"; PASS=$((PASS + 1)); }
fail() { log "  FAIL  $1"; FAIL=$((FAIL + 1)); }

# check <name> <expected_http_code> <actual_http_code>
check() {
  if [ "$2" = "$3" ]; then
    pass "$1 (HTTP $3)"
  else
    fail "$1 (expected HTTP $2, got $3)"
  fi
}

# json_field <json> <field>  -> value of "<field>":"..." in the first JSON object
json_field() {
  printf '%s' "$1" | sed -n "s/.*\"$2\":\"\([^\"]*\)\".*/\1/p" | head -n1
}

# Extract "accessToken" from the login envelope: { "data": { "accessToken": "...", ... }, ... }
extract_token() {
  local json="$1"
  if command -v python >/dev/null 2>&1; then
    python -c "import sys,json; print(json.loads(sys.argv[1])['data']['accessToken'])" "$json" 2>/dev/null
  elif command -v jq >/dev/null 2>&1; then
    printf '%s' "$json" | jq -r '.data.accessToken' 2>/dev/null
  else
    json_field "$json" accessToken
  fi
}

# Extract "id" from a client response envelope: { "data": { "id": "...", ... }, ... }
extract_client_id() {
  local json="$1"
  if command -v python >/dev/null 2>&1; then
    python -c "import sys,json; print(json.loads(sys.argv[1])['data']['id'])" "$json" 2>/dev/null
  elif command -v jq >/dev/null 2>&1; then
    printf '%s' "$json" | jq -r '.data.id' 2>/dev/null
  else
    json_field "$json" id
  fi
}

http_code() { curl -s -o /dev/null -w "%{http_code}" "$@"; }

log "== PMS Customer module smoke test =="
log "Target: $BASE_URL"

# ---- 0. Health ----
CODE=$(http_code "$BASE_URL/api/v1/health")
check "health endpoint is up" 200 "$CODE"
if [ "$CODE" != "200" ]; then
  log ""
  log "ERROR: API is not reachable at $BASE_URL. Start it first:"
  log "  cd apps/backend && dotnet run --project PMS.API.csproj"
  exit 1
fi

# ---- 1. Login ----
LOGIN=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
TOKEN=$(extract_token "$LOGIN")
if [ -n "$TOKEN" ]; then
  pass "admin login returns an access token"
else
  fail "admin login returns an access token (body: $(printf '%s' "$LOGIN" | head -c 200))"
fi
AUTH="Authorization: Bearer $TOKEN"

# ---- 2. Auth guard: no token -> 401 ----
CODE=$(http_code "$BASE_URL/api/v1/clients")
check "clients list without token is rejected" 401 "$CODE"

# ---- 3. List clients ----
LIST=$(curl -s "$BASE_URL/api/v1/clients" -H "$AUTH")
CODE=$(http_code "$BASE_URL/api/v1/clients" -H "$AUTH")
check "clients list (authenticated)" 200 "$CODE"

# ---- 4. Get the first client ----
FIRST_ID=$(python -c "
import sys, json
try:
    data = json.loads(sys.argv[1])['data']
    print(data['items'][0]['id'])
except Exception:
    print('')
" "$LIST" 2>/dev/null)
if [ -n "$FIRST_ID" ]; then
  CODE=$(http_code "$BASE_URL/api/v1/clients/$FIRST_ID" -H "$AUTH")
  check "get client by id ($FIRST_ID)" 200 "$CODE"
else
  fail "get client by id (no client id found in list)"
fi

# ---- 5. Create a client ----
STAMP=$(date +%s)
NAME="SmokeTest-$STAMP"
CREATE=$(curl -s -w $'\n%{http_code}' -X POST "$BASE_URL/api/v1/clients" -H "$AUTH" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$NAME\",\"industry\":\"Technology\"}")
CREATE_BODY=$(printf '%s' "$CREATE" | sed '$d')
CREATE_CODE=$(printf '%s' "$CREATE" | tail -n1)
check "create client '$NAME'" 201 "$CREATE_CODE"
NEW_ID=$(extract_client_id "$CREATE_BODY")
if [ -n "$NEW_ID" ]; then
  pass "created client has an id ($NEW_ID)"
else
  fail "created client has an id (body: $(printf '%s' "$CREATE_BODY" | head -c 200))"
fi

# ---- 6. Update the created client ----
CODE=$(http_code -X PUT "$BASE_URL/api/v1/clients/$NEW_ID" -H "$AUTH" \
  -H "Content-Type: application/json" \
  -d '{"status":"Inactive"}')
check "update client status -> Inactive" 200 "$CODE"

# ---- 7. Validation: empty name -> 400 ----
CODE=$(http_code -X POST "$BASE_URL/api/v1/clients" -H "$AUTH" \
  -H "Content-Type: application/json" \
  -d '{"name":"","industry":""}')
check "create with empty name is rejected (validation)" 400 "$CODE"

# ---- 8. Delete (soft delete) + verify gone ----
CODE=$(http_code -X DELETE "$BASE_URL/api/v1/clients/$NEW_ID" -H "$AUTH")
check "delete created client" 204 "$CODE"
CODE=$(http_code "$BASE_URL/api/v1/clients/$NEW_ID" -H "$AUTH")
check "deleted client is no longer visible" 404 "$CODE"

# ---- Summary ----
log ""
log "== Result: $PASS passed, $FAIL failed =="
if [ "$FAIL" -eq 0 ]; then
  log "Customer module: RUNNING PERFECTLY ✓"
  exit 0
else
  log "Customer module: issues found — see failing checks above."
  exit 1
fi
