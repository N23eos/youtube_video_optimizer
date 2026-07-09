#!/usr/bin/env bash
# youtube_video_optimizer — shrinks videos for streaming/uploading to YouTube.
# Thin wrapper around ffmpeg: 480/720/1080p presets (default 720p), sane defaults.
#
# Requires ffmpeg:  brew install ffmpeg
#
# Examples:
#   ./optimize.sh video.mp4                 # 720p (default)
#   ./optimize.sh -r 1080 video.mp4         # 1080p
#   ./optimize.sh -r 480 -q 25 video.mp4    # 480p, stronger compression
#   ./optimize.sh *.mp4                     # batch over multiple files
#   ./optimize.sh -o out/ ~/Videos/*.mkv    # results into out/ folder

set -euo pipefail

# ---- defaults ----
RES=720            # 480 | 720 | 1080
CRF=""             # quality; empty = auto per resolution (lower = better/larger)
PRESET=medium      # ultrafast..veryslow — slower = smaller file
OUTDIR=""          # empty = next to the source file
SUFFIX="_optimized"

usage() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# ---- argument parsing ----
FILES=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--res)     RES="$2"; shift 2;;
    -q|--crf)     CRF="$2"; shift 2;;
    -p|--preset)  PRESET="$2"; shift 2;;
    -o|--out)     OUTDIR="$2"; shift 2;;
    -h|--help)    usage 0;;
    -*)           echo "Unknown flag: $1" >&2; usage 1;;
    *)            FILES+=("$1"); shift;;
  esac
done

[[ ${#FILES[@]} -eq 0 ]] && { echo "No input file given." >&2; usage 1; }
command -v ffmpeg >/dev/null || { echo "ffmpeg not found. Install it: brew install ffmpeg" >&2; exit 1; }

case "$RES" in
  480)  H=480;  DEF_CRF=23;;
  720)  H=720;  DEF_CRF=23;;
  1080) H=1080; DEF_CRF=22;;
  *) echo "Resolution must be 480, 720 or 1080 (got: $RES)" >&2; exit 1;;
esac
[[ -z "$CRF" ]] && CRF=$DEF_CRF

[[ -n "$OUTDIR" ]] && mkdir -p "$OUTDIR"

human() { # bytes -> human-readable
  awk -v b="$1" 'BEGIN{u="B KB MB GB TB";split(u,a," ");for(i=1;b>=1024&&i<5;i++)b/=1024;printf "%.1f %s",b,a[i]}'
}

optimize_one() {
  local IN="$1"
  [[ -f "$IN" ]] || { echo "Skipping (no such file): $IN" >&2; return; }

  local dir base name out
  dir="$(cd "$(dirname "$IN")" && pwd)"
  base="$(basename "$IN")"; name="${base%.*}"
  if [[ -n "$OUTDIR" ]]; then out="$OUTDIR/${name}${SUFFIX}_${RES}p.mp4"
  else                        out="$dir/${name}${SUFFIX}_${RES}p.mp4"; fi

  # source height — so we never upscale
  local sh
  sh="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$IN" 2>/dev/null || echo 0)"

  # video filter: downscale to target height only if the source is taller; width divisible by 2
  local vf=""
  if [[ "$sh" =~ ^[0-9]+$ && "$sh" -gt "$H" ]]; then
    vf="-vf scale=-2:${H}"
  fi

  # audio: if already AAC — copy losslessly, otherwise re-encode to 160k
  local acodec
  acodec="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$IN" 2>/dev/null || echo none)"
  local aargs=(-c:a aac -b:a 160k)
  [[ "$acodec" == "aac" ]] && aargs=(-c:a copy)

  echo "→ $base  [${RES}p, crf $CRF, preset $PRESET, audio: ${aargs[*]}]"
  ffmpeg -hide_banner -loglevel warning -stats -y -i "$IN" \
    $vf -c:v libx264 -preset "$PRESET" -crf "$CRF" -pix_fmt yuv420p \
    "${aargs[@]}" -movflags +faststart "$out"

  local si so
  si=$(stat -f%z "$IN" 2>/dev/null || stat -c%s "$IN")
  so=$(stat -f%z "$out" 2>/dev/null || stat -c%s "$out")
  local pct; pct=$(awk -v a="$si" -v b="$so" 'BEGIN{printf "%.1f", (1-b/a)*100}')
  echo "  ✓ $(human "$si") → $(human "$so")  (−${pct}%)"
  echo "    $out"
}

for f in "${FILES[@]}"; do optimize_one "$f"; done
