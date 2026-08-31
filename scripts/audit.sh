#!/bin/bash
# audit.sh — снимок состояния системы (read-only, ничего не меняет).
# Полезно запускать до/после оптимизаций и сохранять вывод для сравнения:
#   bash scripts/audit.sh > audit-$(date +%F).txt

set -u
h() { printf '\n══════ %s ══════\n' "$*"; }

h "Система"
sw_vers
uptime

h "Память и своп"
sysctl vm.swapusage
memory_pressure 2>/dev/null | tail -3

h "Диск"
df -h /System/Volumes/Data | awk 'NR<=2'

h "Автозапуск: пользовательские LaunchAgents"
ls -1 "$HOME/Library/LaunchAgents" 2>/dev/null

h "Автозапуск: системные LaunchAgents/Daemons (не Apple)"
ls -1 /Library/LaunchAgents /Library/LaunchDaemons 2>/dev/null
ls -1 /Library/PrivilegedHelperTools 2>/dev/null

h "launchctl: не-Apple службы"
launchctl list 2>/dev/null | grep -iv "com.apple" | sort -t$'\t' -k3

h "brew services"
/opt/homebrew/bin/brew services list 2>/dev/null

h "Топ-10 по CPU"
ps aux -r | head -11 | awk '{printf "%-6s %-5s %s\n", $3, $4, $11}'

h "Топ-10 по памяти"
ps aux -m | head -11 | awk '{printf "%-6s %-5s %s\n", $3, $4, $11}'

h "Крупные папки: Library"
for d in "$HOME/Library/Caches" "$HOME/Library/Logs" "$HOME/Library/Application Support"; do
  du -sh "$d" 2>/dev/null
done
