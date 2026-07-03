#!/bin/bash
# Двойной клик по этому файлу собирает приложение "Optimize Video.app"
# из droplet.applescript. Нужно сделать один раз.
cd "$(dirname "$0")" || exit 1

echo "Собираю Optimize Video.app ..."
rm -rf "Optimize Video.app"
if osacompile -o "Optimize Video.app" droplet.applescript; then
  chmod +x optimize.sh 2>/dev/null
  echo "✓ Готово: $(pwd)/Optimize Video.app"
  echo "Перетаскивай видеофайлы на его иконку. Можно перетащить .app в Dock."
  # проверим ffmpeg
  if ! command -v ffmpeg >/dev/null 2>&1 && ! /opt/homebrew/bin/ffmpeg -version >/dev/null 2>&1 && ! /usr/local/bin/ffmpeg -version >/dev/null 2>&1; then
    echo ""
    echo "⚠  ffmpeg не найден. Установи:  brew install ffmpeg"
  fi
else
  echo "✗ Не удалось собрать приложение."
fi
echo ""
read -n 1 -s -r -p "Нажми любую клавишу, чтобы закрыть..."
