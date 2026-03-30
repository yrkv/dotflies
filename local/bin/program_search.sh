#!/bin/sh

set -euo pipefail
WINDOWS_JSON="$(niri msg -j windows | jq -Mc 'map({title, id, app_id, workspace_id})')"

map_app_id() {
  case "$1" in
    "dev.zed.Zed") echo "zed" ;;
    *) echo "$1" ;;
  esac
}

niri msg action open-overview
SELECTED_INDEX="$(echo $WINDOWS_JSON \
  | jq '
def map_app_id: {
  "dev.zed.Zed":"zed",
}[.] // .;
.[] | "\(.app_id): \(.title)\u0000icon\u001f\(.app_id | map_app_id)"
' -r \
  | fuzzel --dmenu --index -w 40 -l 10 --counter --keyboard-focus on-demand --namespace 'program_search.sh')" || {
    niri msg action close-overview;
    exit 1;
  }

SELECTED_ID="$(echo $WINDOWS_JSON | jq ".[$SELECTED_INDEX].id")"
niri msg action focus-window --id "$SELECTED_ID"
niri msg action close-overview;

