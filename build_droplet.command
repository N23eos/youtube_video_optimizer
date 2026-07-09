#!/bin/bash
# Double-click this file to build the "Optimize Video.app" application
# from droplet.applescript. Needs to be done once.
cd "$(dirname "$0")" || exit 1

echo "Building Optimize Video.app ..."
rm -rf "Optimize Video.app"
if osacompile -o "Optimize Video.app" droplet.applescript; then
  chmod +x optimize.sh 2>/dev/null
  echo "✓ Done: $(pwd)/Optimize Video.app"
  echo "Drag video files onto its icon. You can also drop the .app into the Dock."
  # check for ffmpeg
  if ! command -v ffmpeg >/dev/null 2>&1 && ! /opt/homebrew/bin/ffmpeg -version >/dev/null 2>&1 && ! /usr/local/bin/ffmpeg -version >/dev/null 2>&1; then
    echo ""
    echo "⚠  ffmpeg not found. Install it:  brew install ffmpeg"
  fi
else
  echo "✗ Failed to build the app."
fi
echo ""
read -n 1 -s -r -p "Press any key to close..."
