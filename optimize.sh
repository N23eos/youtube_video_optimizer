#!/usr/bin/env bash
# youtube_video_optimizer — ужимает видео для стриминга/загрузки на YouTube.
# Обёртка вокруг ffmpeg: пресеты 480/720/1080p (дефолт 720p), умные дефолты.
#
# Требуется ffmpeg:  brew install ffmpeg
#
# Примеры:
#   ./optimize.sh video.mp4                 # 720p (дефолт)
#   ./optimize.sh -r 1080 video.mp4         # 1080p
#   ./optimize.sh -r 480 -q 25 video.mp4    # 480p, сильнее сжатие
#   ./optimize.sh *.mp4                     # батч по нескольким файлам
#   ./optimize.sh -o out/ ~/Videos/*.mkv    # результат в папку out/

set -euo pipefail

# ---- дефолты ----
RES=720            # 480 | 720 | 1080
CRF=""             # качество; пусто = авто по разрешению (меньше = лучше/крупнее)
PRESET=medium      # ultrafast..veryslow — медленнее = меньше файл
OUTDIR=""          # пусто = рядом с исходником
SUFFIX="_optimized"

usage() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# ---- разбор аргументов ----
FILES=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--res)     RES="$2"; shift 2;;
    -q|--crf)     CRF="$2"; shift 2;;
    -p|--preset)  PRESET="$2"; shift 2;;
    -o|--out)     OUTDIR="$2"; shift 2;;
    -h|--help)    usage 0;;
    -*)           echo "Неизвестный флаг: $1" >&2; usage 1;;
    *)            FILES+=("$1"); shift;;
  esac
done

[[ ${#FILES[@]} -eq 0 ]] && { echo "Не указан входной файл." >&2; usage 1; }
command -v ffmpeg >/dev/null || { echo "ffmpeg не найден. Установи: brew install ffmpeg" >&2; exit 1; }

case "$RES" in
  480)  H=480;  DEF_CRF=23;;
  720)  H=720;  DEF_CRF=23;;
  1080) H=1080; DEF_CRF=22;;
  *) echo "Разрешение должно быть 480, 720 или 1080 (задано: $RES)" >&2; exit 1;;
esac
[[ -z "$CRF" ]] && CRF=$DEF_CRF

[[ -n "$OUTDIR" ]] && mkdir -p "$OUTDIR"

human() { # байты -> человекочитаемо
  awk -v b="$1" 'BEGIN{u="B KB MB GB TB";split(u,a," ");for(i=1;b>=1024&&i<5;i++)b/=1024;printf "%.1f %s",b,a[i]}'
}

optimize_one() {
  local IN="$1"
  [[ -f "$IN" ]] || { echo "Пропуск (нет файла): $IN" >&2; return; }

  local dir base name out
  dir="$(cd "$(dirname "$IN")" && pwd)"
  base="$(basename "$IN")"; name="${base%.*}"
  if [[ -n "$OUTDIR" ]]; then out="$OUTDIR/${name}${SUFFIX}_${RES}p.mp4"
  else                        out="$dir/${name}${SUFFIX}_${RES}p.mp4"; fi

  # исходная высота — чтобы не апскейлить
  local sh
  sh="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$IN" 2>/dev/null || echo 0)"

  # видеофильтр: даунскейл до целевой высоты только если исходник больше; ширина кратна 2
  local vf=""
  if [[ "$sh" =~ ^[0-9]+$ && "$sh" -gt "$H" ]]; then
    vf="-vf scale=-2:${H}"
  fi

  # аудио: если уже AAC — копируем без потерь, иначе перекодируем в 160k
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
