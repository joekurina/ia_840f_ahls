#!/usr/bin/env bash
# rd.sh - drive owned remote tmux window qsys_import_01 (Agilex7Workstation)
# usage: rd.sh send '<text>' | enter | cap [lines] | bufput <localfile> <bufname> | bufget <bufname> <localfile>
set -u
HOST=uwb_student00@100.101.227.97
SESS=ia840f_mailbox_monitored_01
WIN=qsys_import_01
TGT="$SESS:$WIN"
case "${1:-}" in
  send) shift; txt="$*"; ssh "$HOST" tmux send-keys -t "$TGT" -l -- "$(printf '%q' "$txt")" && ssh "$HOST" tmux send-keys -t "$TGT" Enter ;;
  enter) ssh "$HOST" tmux send-keys -t "$TGT" Enter ;;
  cap) ssh "$HOST" tmux capture-pane -p -t "$TGT" -S -"${2:-80}" ;;
  bufput) cat "$2" | ssh "$HOST" tmux load-buffer -b "$3" - ;;
  bufget) ssh "$HOST" tmux save-buffer -b "$2" - > "$3" ;;
  *) echo "usage: rd.sh send|enter|cap|bufput|bufget" >&2; exit 2 ;;
esac
