#!/usr/bin/env bash
# Runs on the Steam Frame (piped over SSH): opens a OneClick link in the graphical
# session, so the Frame's own handler (BSManager) downloads and installs it.
#
# Usage: remote.sh <url> [<beatsaver map id>...]
#
# With map ids, it then watches BSManager's log and map folders until those maps are
# installed, and reports on stdout, one event per line:
#   received              BSManager got the link
#   downloading <id>      BSManager started downloading a map
#   done <id>             the map's folder was (re)written and is complete
#   error <message>       BSManager logged an error (may be unrelated)
#   result <id> new|already|missing
set -euo pipefail

url=$1
shift
ids=("$@")
uid=$(id -u)

# BSManager's default locations (installation folder not changed)
bsm=$HOME/.local/share/BSManager
logs=$HOME/.config/bs-manager/logs

# Give up when nothing has happened for this long (BSManager may need to start first)
timeout=120
# With maps that were already installed, finish once BSManager is quiet for this long
quiet=10

for id in "${ids[@]}"; do
  if [[ ! $id =~ ^[0-9a-f]+$ ]]; then
    echo "Invalid map id: $id" >&2
    exit 1
  fi
done

# An SSH session has no display. Borrow the display variables from a process in
# the graphical session, preferring the Steam client.
session_env() {
  local pid env
  for pid in $(pgrep -u "$uid" -x steam || true) $(pgrep -u "$uid"); do
    env=$(tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null) || continue
    if grep -qE '^(DISPLAY|WAYLAND_DISPLAY)=' <<<"$env"; then
      printf '%s\n' "$env"
      return 0
    fi
  done
  return 1
}

if ! env=$(session_env); then
  echo "No graphical session found on the Frame (is it signed in?)" >&2
  exit 1
fi

while IFS= read -r line; do
  export "${line?}"
done < <(grep -E '^(DISPLAY|WAYLAND_DISPLAY|XAUTHORITY|XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE|DBUS_SESSION_BUS_ADDRESS)=' <<<"$env")

opener=
for candidate in gio xdg-open kde-open; do
  if command -v "$candidate" >/dev/null; then
    opener=$candidate
    break
  fi
done
if [[ -z $opener ]]; then
  echo "No gio, xdg-open or kde-open on the Frame" >&2
  exit 1
fi
open_cmd=("$opener")
[[ $opener == gio ]] && open_cmd+=(open)

map_dirs=("$bsm"/BSInstances/*/"Beat Saber_Data"/CustomLevels "$bsm"/SharedContent/SharedMaps/CustomLevels)

# Prints "<newest change time> <total size>" over a map's folders in all instances,
# or "none". Change time (not mtime), as extracting may keep the zip's mtimes.
map_state() {
  local d f t s newest=0 size=0 found=
  for d in "${map_dirs[@]}"; do
    for f in "$d/$1 ("*; do
      [[ -d $f ]] || continue
      found=1
      t=$(find "$f" -printf '%C@\n' | sort -n | tail -n1)
      t=${t%.*}
      ((t > newest)) && newest=$t
      s=$(du -sb "$f" | cut -f1)
      size=$((size + s))
    done
  done
  if [[ -n $found ]]; then echo "$newest $size"; else echo none; fi
}

# BSManager log lines written since we started. Continuation lines (stack traces)
# don't start with a timestamp and are left out.
log_since_start() {
  find "$logs" -name '*.log' -newermt "@$start" -print0 2>/dev/null |
    xargs -0r cat |
    awk -v s="[$start_log" 'substr($0, 1, 20) >= s'
}

declare -A pre state prev
for id in "${ids[@]}"; do
  pre[$id]=$(map_state "$id")
  state[$id]=pending
  prev[$id]=
done

start=$(date +%s)
start_log=$(date -d "@$start" '+%Y-%m-%d %H:%M:%S')

# gio comes first: xdg-open (generic mode) mangles the quoted path in BSManager's Exec line.
# Run it in its own scope, detached from this SSH session: if BSManager isn't running
# yet, the handler starts it, and it must outlive the connection. Output goes to the
# journal: journalctl --user -t beatsaber-oneclick
systemd-run --user --scope --collect --quiet \
  setsid -f systemd-cat -t beatsaber-oneclick "${open_cmd[@]}" "$url" \
  </dev/null >/dev/null 2>&1

((${#ids[@]} > 0)) || exit 0

received=
errors_seen=0
last_activity=$start
while :; do
  sleep 1
  now=$(date +%s)
  lines=$(log_since_start)

  if [[ -z $received ]] && grep -q 'DEEP-LINK RECEIVED' <<<"$lines"; then
    received=1
    last_activity=$now
    echo received
  fi

  mapfile -t errors < <(grep -F '[error]' <<<"$lines" || true)
  for err in "${errors[@]:errors_seen}"; do
    echo "error ${err#*\[error\] }"
  done
  errors_seen=${#errors[@]}

  waiting=0
  all_done=1
  for id in "${ids[@]}"; do
    [[ ${state[$id]} == installed ]] && continue
    all_done=

    if [[ ${state[$id]} == pending ]] && grep -qF " $id https://" <<<"$lines"; then
      state[$id]=downloading
      last_activity=$now
      echo "downloading $id"
    fi

    # Done once the folder changed since we started and stayed the same for a second
    cur=$(map_state "$id")
    if [[ $cur != none ]] && ((${cur%% *} >= start)); then
      if [[ $cur == "${prev[$id]}" ]]; then
        state[$id]=installed
        last_activity=$now
        echo "done $id"
        continue
      fi
      prev[$id]=$cur
      last_activity=$now
    fi

    # Maps that weren't installed yet, or are being downloaded, are worth waiting for
    if [[ ${state[$id]} == downloading || ${pre[$id]} == none ]]; then
      waiting=$((waiting + 1))
    fi
  done

  [[ -n $all_done ]] && break
  [[ -n $received ]] && ((waiting == 0 && now - last_activity >= quiet)) && break
  ((now - last_activity >= timeout)) && break
done

for id in "${ids[@]}"; do
  if [[ ${state[$id]} == installed ]]; then
    echo "result $id new"
  elif [[ ${pre[$id]} != none ]]; then
    echo "result $id already"
  else
    echo "result $id missing"
  fi
done
