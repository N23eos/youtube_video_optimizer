# AGENTS.md — guide for AI coding agents

This repo is a thin bash wrapper around **ffmpeg** that compresses videos for YouTube upload/streaming, plus a macOS drag-and-drop droplet. If a user asks you to "optimize", "compress", "shrink" or "transcode" a video for YouTube, use `optimize.sh` directly — do not write new ffmpeg commands.

## Quick start (transcoding a video)

```bash
# prerequisite (macOS): brew install ffmpeg
./optimize.sh video.mp4              # 720p, CRF 23 (default, best for most cases)
./optimize.sh -r 1080 video.mp4      # 1080p, CRF 22
./optimize.sh -r 480 video.mp4       # 480p, maximum space saving
./optimize.sh -q 25 video.mp4        # stronger compression (higher CRF = smaller file)
./optimize.sh -p slow video.mp4      # slower encode, slightly smaller file
./optimize.sh -o out/ *.mp4          # batch mode, results into out/
```

Output: `<name>_optimized_<res>p.mp4` next to the source (or in `-o` dir). The script never overwrites the source file.

## Flags

| Flag | Meaning | Default |
|------|---------|---------|
| `-r`, `--res` | target height: 480, 720 or 1080 | 720 |
| `-q`, `--crf` | H.264 CRF quality (lower = better/larger) | 23 (22 for 1080p) |
| `-p`, `--preset` | ffmpeg preset, ultrafast..veryslow | medium |
| `-o`, `--out` | output directory | next to source |
| `-h`, `--help` | usage | |

## Behavior guarantees (do not break these when editing)

- Never upscales: downscales only if source height > target.
- Audio: copies AAC streams losslessly (`-c:a copy`); otherwise re-encodes to AAC 160k.
- Always outputs H.264 + yuv420p + `-movflags +faststart` (streaming-ready mp4).
- Prints a before/after size report per file.
- Exits non-zero with a clear message if ffmpeg is missing or resolution is invalid.

## Repo layout

| File | Purpose |
|------|---------|
| `optimize.sh` | the CLI; all encoding logic lives here |
| `droplet.applescript` | macOS droplet UI; calls `optimize.sh` |
| `build_droplet.command` | builds `Optimize Video.app` via `osacompile` |
| `.claude/skills/video-optimize/` | Claude Code skill wrapping the CLI |
| `ROADMAP.md` | planned features |

## Conventions

- Bash with `set -euo pipefail`; keep it POSIX-macOS compatible (script uses `stat -f%z || stat -c%s` to work on both macOS and Linux).
- Verify script changes with `bash -n optimize.sh` and, if available, `shellcheck`.
- Test on a small sample video across all three presets (480/720/1080) before committing encoding changes.
- The droplet and `optimize.sh` must stay in the same folder — the droplet resolves the script path relative to itself.
