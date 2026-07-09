---
name: video-optimize
description: Compress and transcode video files for YouTube upload or streaming using this repo's optimize.sh (ffmpeg wrapper). Use when the user asks to optimize, compress, shrink, downscale, re-encode or transcode a video, reduce a video's file size, or prepare a video for YouTube — at 480p, 720p or 1080p.
---

# Video optimize (YouTube presets)

Use `optimize.sh` at the repo root. It wraps ffmpeg with tested presets — do not compose raw ffmpeg commands for tasks it covers.

## Steps

1. Check ffmpeg is installed: `command -v ffmpeg`. If missing, tell the user to run `brew install ffmpeg` (macOS) or install via their package manager.
2. Pick the resolution: 720p is the default and right for most uploads; 1080p to keep more detail; 480p for maximum space saving. If the user did not specify, use 720p.
3. Run:

```bash
./optimize.sh [-r 480|720|1080] [-q CRF] [-p preset] [-o outdir] <files...>
```

4. Report the before → after sizes the script prints, and the output path.

## Examples

```bash
./optimize.sh lecture.mp4                 # 720p default
./optimize.sh -r 1080 talk.mov            # 1080p
./optimize.sh -q 25 big.mp4               # smaller file, slightly lower quality
./optimize.sh -o compressed/ *.mp4        # batch into compressed/
```

## Notes

- Output is `<name>_optimized_<res>p.mp4`; the source file is never modified.
- The script never upscales; if the source is already ≤ target height, it only re-encodes.
- AAC audio is copied losslessly; other codecs are re-encoded to AAC 160k.
- Output is streaming-ready (H.264, yuv420p, `+faststart`).
- Encoding is CPU-bound and can take minutes for long videos — use a longer timeout or run in background for files over a few hundred MB.
- Choosing CRF: 18–22 near-transparent quality, 23 default, 25–28 aggressive compression. Lower = better quality, bigger file.
