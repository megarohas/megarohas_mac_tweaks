#!/bin/bash
# cleanup_user.sh — пользовательская чистка (без sudo).
# Все пункты одобрены владельцем 2026-08-31 (docs/decisions.md).
# Запуск:  bash scripts/cleanup_user.sh
# Дампы удаляемых баз PostgreSQL уже лежат в ~/MacTweaksBackup-2026-08-31/db-dumps
# (создаются ЗАРАНЕЕ; скрипт откажется удалять базу без дампа).

set -u
BK="$HOME/MacTweaksBackup-2026-08-31"
say() { printf '\n═══ %s ═══\n' "$*"; }

say "1/6 PostgreSQL: phantom и thehubblog (только при наличии дампа)"
if [ -s "$BK/db-dumps/phantom.pgdump" ]; then
  dropdb --if-exists phantom 2>/dev/null && echo "  ✕ база phantom удалена"
else
  echo "  ⚠ нет дампа phantom — пропуск"
fi
if [ -s "$BK/db-dumps/thehubblog.pgdump" ]; then
  dropdb --if-exists thehubblog 2>/dev/null && echo "  ✕ база thehubblog удалена"
else
  echo "  ⚠ нет дампа thehubblog — пропуск"
fi

say "2/6 Видео-обои macOS (система перекачает выбранные при необходимости)"
rm -f "$HOME/Library/Application Support/com.apple.wallpaper/aerials/videos/"*.mov 2>/dev/null
echo "  ✕ aerials/videos очищено"

say "3/6 Хвост удалённого Яндекс.Браузера"
rm -rf "$HOME/Library/Application Support/Yandex" "$HOME/Library/Caches/Yandex" 2>/dev/null
echo "  ✕ Application Support/Yandex + Caches/Yandex"

say "4/6 Сейвы Paradox Interactive (игры удалены)"
rm -rf "$HOME/Library/Application Support/Paradox Interactive" 2>/dev/null
echo "  ✕ Application Support/Paradox Interactive"

say "5/6 Loopback (приложение) + пользовательские данные TeamViewer"
rm -rf "$HOME/Library/Application Support/Loopback" 2>/dev/null
rm -rf "$HOME/Library/Application Support/TeamViewer" 2>/dev/null
echo "  ✕ Loopback.app и настройки TeamViewer"

say "6/6 Разовая чистка dev-кэшей (дальше это делает janitor)"
rm -rf "$HOME/Library/Caches/ms-playwright" \
       "$HOME/Library/Caches/Yarn" \
       "$HOME/.cache/yarn" \
       "$HOME/Library/Caches/node-gyp" \
       "$HOME/Library/Caches/com.googlecode.iterm2" 2>/dev/null
find "$HOME/.cache" -type f -mtime +7 -delete 2>/dev/null
echo "  ✕ playwright / yarn / node-gyp / iTerm2 / ~/.cache (старое)"

echo
echo "✅ Пользовательская чистка завершена."
df -h "$HOME" | awk 'NR<=2'
