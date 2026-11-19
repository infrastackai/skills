#!/bin/sh
# InfraStack Live for coding agents: sign in through the browser and read the threat pages, with the token kept in the
# plugin's own data folder and never printed, never on a command line, never in the agent's context.
#
#   infrastack.sh --data DIR login start [CLIENT]   show the code, open the browser
#   infrastack.sh --data DIR login wait             wait up to 90 s for the person to allow it; run again if pending
#   infrastack.sh --data DIR get URL                one page from https://infrastack.ai/ (signed in when there is a token)
#   infrastack.sh --data DIR status                 signed in or not
#   infrastack.sh --data DIR logout                 forget the token here
set -eu

BASE="https://infrastack.ai"
DATA=""
if [ "${1:-}" = "--data" ]; then DATA="${2:-}"; shift 2; fi
[ -n "$DATA" ] || { echo "infrastack: --data <plugin data folder> is required" >&2; exit 2; }
umask 077
mkdir -p "$DATA"
TOKEN="$DATA/token"
PENDING="$DATA/login.pending"

field() { # a string field from a one-line JSON answer, or nothing
  sed -nE "s/.*\"$1\" *: *\"([^\"]*)\".*/\\1/p" | head -n 1
}
number() {
  sed -nE "s/.*\"$1\" *: *([0-9]+).*/\\1/p" | head -n 1
}

cmd="${1:-}"
[ $# -gt 0 ] && shift
case "$cmd" in
  login)
    case "${1:-}" in
      start)
        client=$(printf %s "${2:-Claude Code}" | tr -cd 'A-Za-z0-9 ._-' | cut -c1-40)
        answer=$(curl -sS -X POST "$BASE/api/agent/login/start" -H 'content-type: application/json' -d "{\"client\":\"$client\"}")
        device=$(printf %s "$answer" | field device_code)
        code=$(printf %s "$answer" | field user_code)
        url=$(printf %s "$answer" | field verification_uri_complete)
        interval=$(printf %s "$answer" | number interval)
        [ -n "$device" ] && [ -n "$code" ] || { echo "infrastack: sign-in could not start"; exit 1; }
        # the server's device code goes back into JSON: only its own shape is accepted
        printf %s "$device" | grep -Eq '^dvc_[A-Za-z0-9_-]{30,80}$' || { echo "infrastack: unexpected sign-in answer; stopped"; exit 1; }
        case "$url" in
          "$BASE"/*) ;;
          *) echo "infrastack: the sign-in address is not infrastack.ai; stopped"; exit 1 ;;
        esac
        printf '%s %s\n' "$device" "${interval:-5}" > "$PENDING"
        echo "Code: $code"
        echo "Open: $url"
        if command -v open >/dev/null 2>&1; then open "$url" >/dev/null 2>&1 || true
        elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$url" >/dev/null 2>&1 || true
        fi
        echo "Ask the person to sign in and allow it if the code matches, then run: login wait"
        ;;
      wait)
        [ -f "$PENDING" ] || { echo "infrastack: no sign-in in progress; run login start"; exit 1; }
        read -r device interval < "$PENDING"
        tries=$((90 / ${interval:-5}))
        printf %s "$device" | grep -Eq '^dvc_[A-Za-z0-9_-]{30,80}$' || { rm -f "$PENDING"; echo "infrastack: no valid sign-in in progress; run login start"; exit 1; }
        while [ "$tries" -gt 0 ]; do
          # the answer stays in memory (no file): its body, then the status on the last line
          answer=$(curl -sS -w '\n%{http_code}' -X POST "$BASE/api/agent/login/poll" -H 'content-type: application/json' -d "{\"device_code\":\"$device\"}" || printf '\n000')
          status=$(printf %s "$answer" | tail -n 1)
          body=$(printf %s "$answer" | sed '$d')
          if [ "$status" = "200" ]; then
            printf %s "$body" | field token > "$TOKEN"
            rm -f "$PENDING"
            if [ -s "$TOKEN" ]; then echo "Signed in. The key is saved in the plugin's data folder; it lasts 90 days from its last use."; exit 0; fi
            rm -f "$TOKEN"; echo "infrastack: sign-in answered without a key"; exit 1
          fi
          err=$(printf %s "$body" | field error)
          case "$err" in
            authorization_pending|slow_down) sleep "${interval:-5}"; tries=$((tries - 1)) ;;
            access_denied) rm -f "$PENDING"; echo "infrastack: the person declined the sign-in"; exit 1 ;;
            expired_token) rm -f "$PENDING"; echo "infrastack: the code expired; run login start again"; exit 1 ;;
            *) echo "infrastack: sign-in check failed (HTTP $status)"; exit 1 ;;
          esac
        done
        echo "Still waiting for the person to allow it. Run login wait again (ten minutes at most in all)."
        ;;
      *) echo "usage: login start [CLIENT] | login wait" >&2; exit 2 ;;
    esac
    ;;
  get)
    url="${1:-}"
    case "$url" in
      "$BASE"/*) ;;
      *) echo "infrastack: only https://infrastack.ai/ pages" >&2; exit 2 ;;
    esac
    if [ -s "$TOKEN" ]; then
      # the header goes to curl on stdin: no file, nothing on the command line
      printf 'Authorization: Bearer %s\n' "$(cat "$TOKEN")" | curl -sS -H @- -w '\n[HTTP %{http_code}]\n' "$url"
    else
      curl -sS -w '\n[HTTP %{http_code}]\n' "$url"
    fi
    ;;
  status)
    if [ -s "$TOKEN" ]; then echo "signed in"; else echo "not signed in"; fi
    ;;
  logout)
    rm -f "$TOKEN" "$PENDING"
    echo "Signed out here. To end the key everywhere, sign it out on the InfraStack dashboard."
    ;;
  *)
    sed -n '4,9p' "$0" >&2
    exit 2
    ;;
esac
