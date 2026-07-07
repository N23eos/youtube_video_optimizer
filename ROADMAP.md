# Roadmap — youtube_video_optimizer

Обёртка вокруг ffmpeg: пресеты сжатия видео для YouTube + drag-and-drop droplet (macOS).
Статус: v0.1 — рабочий CLI (optimize.sh) и droplet собраны.

## Вехи
- [x] CLI `optimize.sh` с флагами -r/-q/-p/-o
- [x] macOS drag-and-drop droplet (build_droplet.command, droplet.applescript)
- [ ] **v1.0** — стабилизировать CLI: прогресс-бар, обработка ошибок, проверка наличия ffmpeg
- [ ] **v1.1** — пресеты под формат: Shorts/вертикаль 9:16, обычный 16:9
- [ ] **v1.2** — авто-битрейт по длине/разрешению, отчёт «было → стало» (размер, %)
- [ ] **v2.0** — простой GUI поверх droplet (выбор пресета до конвертации)
