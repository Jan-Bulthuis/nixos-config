# Forwards a Beat Saber OneClick link to the Steam Frame, where BSManager downloads it,
# and keeps a desktop notification up to date until the install is done.
# Usage: beatsaber-oneclick <ssh-host> <url>
# $remote_script (remote.sh) is set by the package.

host=${1:?usage: beatsaber-oneclick <ssh-host> <url>}
url=${2:?usage: beatsaber-oneclick <ssh-host> <url>}
api=https://api.beatsaver.com

# One notification, updated in place
notification_id=
notify() {
  local id
  if id=$(notify-send --print-id ${notification_id:+--replace-id="$notification_id"} \
    --app-name="Beat Saber OneClick" --icon=input-gaming "$@"); then
    notification_id=$id
  fi
}

# Only forward the OneClick schemes, and only plain URL characters, since the URL
# ends up in a remote shell command line.
if [[ ! $url =~ ^(beatsaver|bsplaylist|web\+bsmap|modelsaber):// ]] ||
  [[ ! $url =~ ^[A-Za-z0-9+.:/?#\&=%_~@!,\;-]+$ ]]; then
  notify --urgency=critical "Not a OneClick link" "$url"
  exit 1
fi

fetch() {
  curl -sfL --max-time 20 "$@"
}

# Look up what the link installs, to know which map folders to watch for. If that
# fails, the link is still sent, just without tracking.
ids=()
label=$url
playlist=
case $url in
beatsaver://* | web+bsmap://*)
  ref=${url#*://}
  ref=${ref%%[/?#]*}
  if [[ $url == beatsaver://* ]]; then
    map=$(fetch "$api/maps/id/$ref") || map=
  else
    map=$(fetch "$api/maps/hash/$ref") || map=
  fi
  if [[ -n $map ]]; then
    ids=("$(jq -r '.id | ascii_downcase' <<<"$map")")
    label=$(jq -r '"\(.metadata.songName) – \(.metadata.levelAuthorName)"' <<<"$map")
  fi
  ;;
bsplaylist://playlist/*)
  playlist=1
  label="Playlist"
  if bplist=$(fetch "${url#bsplaylist://playlist/}"); then
    label=$(jq -r '.playlistTitle // "Playlist"' <<<"$bplist")
    # Entries with a key need no lookup; resolve the rest by hash, 50 at a time
    mapfile -t ids < <(jq -r '.songs[] | .key // empty | ascii_downcase' <<<"$bplist")
    mapfile -t hashes < <(jq -r '.songs[] | select(.key == null) | .hash // empty | ascii_downcase' <<<"$bplist")
    for ((i = 0; i < ${#hashes[@]}; i += 50)); do
      batch=$(
        IFS=,
        echo "${hashes[*]:i:50}"
      )
      if found=$(fetch "$api/maps/hash/$batch"); then
        # A single hash returns the map itself instead of a hash → map object
        mapfile -t -O "${#ids[@]}" ids < <(jq -r 'if has("id") then .id else (.[] | select(. != null) | .id) end | ascii_downcase' <<<"$found")
      fi
    done
  fi
  ;;
esac

notify "Sending to Steam Frame…" "$label"

total=${#ids[@]}
done_count=0
new=0
already=0
missing=0
last_error=
stderr_file=$(mktemp)
trap 'rm -f "$stderr_file"' EXIT

exec {events}< <(ssh -T -o BatchMode=yes -o ConnectTimeout=5 "$host" \
  bash -s -- "$(printf '%q' "$url")" "${ids[@]}" <"$remote_script" 2>"$stderr_file")
ssh_pid=$!

while IFS= read -r -u "$events" event; do
  case $event in
  received)
    notify "Downloading on Steam Frame…" "$label"
    ;;
  "done "*)
    done_count=$((done_count + 1))
    if ((total > 1)); then
      notify "Downloading on Steam Frame… $done_count/$total" "$label"
    fi
    ;;
  "error "*)
    last_error=${event#error }
    ;;
  "result "*" new") new=$((new + 1)) ;;
  "result "*" already") already=$((already + 1)) ;;
  "result "*" missing") missing=$((missing + 1)) ;;
  esac
done

if ! wait "$ssh_pid"; then
  err=$(tr -d '\r' <"$stderr_file" | grep -v 'X11 forwarding' || true)
  notify --urgency=critical "Couldn't send to Steam Frame" "${err:-ssh failed}"
  exit 1
fi

failure_hint=${last_error:-BSManager didn\'t finish within 2 minutes. Check it on the Frame.}

if ((total == 0)); then
  notify "Sent to Steam Frame" "$label"$'\n(Not tracked: couldn\'t look it up on BeatSaver.)'
elif [[ -z $playlist ]]; then
  if ((new > 0)); then
    notify "Installed on Steam Frame" "$label"
  elif ((already > 0)); then
    notify "Already on Steam Frame" "$label"
  else
    notify --urgency=critical "Not installed on Steam Frame" "$label"$'\n'"$failure_hint"
  fi
else
  summary="$label: $new new, $already already there"
  if ((missing > 0)); then
    notify --urgency=critical "Playlist partly installed on Steam Frame" \
      "$summary, $missing failed"$'\n'"$failure_hint"
  else
    notify "Playlist installed on Steam Frame" "$summary"
  fi
fi
