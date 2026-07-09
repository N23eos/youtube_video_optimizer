# Roadmap — youtube_video_optimizer

A wrapper around ffmpeg: video compression presets for YouTube + drag-and-drop droplet (macOS).
Status: v0.1 — working CLI (optimize.sh) and droplet built.

## Milestones

- [x] CLI `optimize.sh` with -r/-q/-p/-o flags
- [x] macOS drag-and-drop droplet (build_droplet.command, droplet.applescript)
- [x] Agent support: AGENTS.md + Claude Code skill (`.claude/skills/video-optimize`)
- [ ] **v1.0** — stabilize the CLI: progress bar, error handling, ffmpeg presence check
- [ ] **v1.1** — format presets: Shorts/vertical 9:16, regular 16:9
- [ ] **v1.2** — auto bitrate by duration/resolution, "before → after" report (size, %)
- [ ] **v2.0** — simple GUI on top of the droplet (preset selection before conversion)
