#!/bin/bash
# dev.sh — управление локальным дев-стеком одним словом.
# Базы переведены в ручной режим 2026-08-31: не висят в памяти, пока не нужны.
#
#   dev up              — поднять весь стек (mysql redis rabbitmq)
#   dev up mysql        — поднять только mysql
#   dev down [svc...]   — погасить
#   dev status          — состояние всех сервисов
#
# `brew services run` стартует сервис БЕЗ добавления в автозапуск — в этом идея.
# PostgreSQL@14 остаётся в автозапуске (решение владельца), MongoDB — свой
# LaunchAgent com.megarohas.mongod. Их этот скрипт не трогает.
#
# Ручной режим — решение от 2026-08-31, не догма. Если какой-то сервис снова
# нужен постоянно: `brew services start <svc>` вернёт его в автозапуск, и этот
# скрипт просто перестанет быть для него нужным.
#
# Установка алиаса:  echo 'alias dev="bash $HOME/Dev\ Projects/megarohas_mac_tweaks/scripts/dev.sh"' >> ~/.zshrc

set -u
ALL=(mysql redis rabbitmq)
BREW=/opt/homebrew/bin/brew

cmd="${1:-status}"; shift 2>/dev/null || true
svcs=("$@"); [ ${#svcs[@]} -eq 0 ] && svcs=("${ALL[@]}")

case "$cmd" in
  up)
    for s in "${svcs[@]}"; do echo "▶ $s"; "$BREW" services run "$s"; done ;;
  down)
    for s in "${svcs[@]}"; do echo "⏹ $s"; "$BREW" services stop "$s"; done ;;
  status)
    "$BREW" services list
    echo
    pgrep -x mongod >/dev/null && echo "mongod: работает (LaunchAgent)" || echo "mongod: остановлен" ;;
  *)
    echo "usage: dev up|down|status [mysql|redis|rabbitmq ...]"; exit 1 ;;
esac
