<p align="center"><img src="assets/readme-header.png" alt="" width="480"></p>

# youtube_video_optimizer

Shrinks video files for uploading/streaming to YouTube. It's a thin wrapper around **ffmpeg** — ffmpeg does all the work; the script just fixes convenient presets and sensible defaults.

## Install

```bash
brew install ffmpeg      # if you don't have it yet
chmod +x optimize.sh     # once
```

## Usage

```bash
./optimize.sh video.mp4              # 720p (default)
./optimize.sh -r 1080 video.mp4      # 1080p
./optimize.sh -r 480 video.mp4       # 480p (maximum space saving)
./optimize.sh -q 25 video.mp4        # compress harder (higher CRF = smaller file)
./optimize.sh -p slow video.mp4      # slower encode, slightly smaller file
./optimize.sh -o out/ *.mp4          # batch, output into out/ folder
```

Flags: `-r` resolution (480/720/1080), `-q` CRF quality (lower = better), `-p` ffmpeg preset, `-o` output folder, `-h` help.

## Drag-and-drop (macOS)

Build the app once — double-click **`build_droplet.command`** and it creates `Optimize Video.app` next to it
(on first launch: right-click → "Open" to get past Gatekeeper).

After that, just **drag video files onto the app icon** → pick a resolution (480/720/1080) → done.
You can drop the app into the Dock. Internally it calls `optimize.sh`, so both files must live in the same folder.

Sources: `droplet.applescript` (logic) and `build_droplet.command` (builder).

## What it does

- H.264, `-crf` (constant quality): 480/720p → 23, 1080p → 22.
- Downscales only if the source is taller than the target (never upscales).
- Audio: if already AAC, copies it without re-encoding (no loss or clicks), otherwise re-encodes to AAC 160k.
- `+faststart` — moves the moov atom to the front, ready for streaming.
- Output name: `<name>_optimized_<res>p.mp4`.

## For AI agents

The repo ships with agent support out of the box:

- **`AGENTS.md`** — instructions for any coding agent (Claude Code, Cursor, Codex, …): how to run the CLI, flags, behavior guarantees, conventions.
- **`.claude/skills/video-optimize/`** — a [Claude Code skill](https://code.claude.com/docs/en/skills): ask Claude to "compress this video for YouTube" inside the repo and it will use `optimize.sh` with the right preset.

## Benchmark

Meditative lofi, 68 min: **6.2 GB → 625 MB** (−89%) at 720p with no visible quality loss. Source files often ship with an inflated bitrate (~12 Mbps for 720p vs. YouTube's recommended ~5 Mbps), which leaves plenty of headroom for compression.

## License

[MIT](LICENSE)

## Support

If this project was useful to you, feel free to support further development:

[![ETH](https://img.shields.io/badge/ETH-0x7777...88C4-blue?logo=ethereum&style=flat-square)](https://etherscan.io/address/0x77777da54702AC8789D53fc7cC6201C29a1A88C4)
[![Donate](https://img.shields.io/badge/donate-crypto-orange?style=flat-square)](https://etherscan.io/address/0x77777da54702AC8789D53fc7cC6201C29a1A88C4)
