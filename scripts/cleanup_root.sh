#!/bin/bash
# cleanup_root.sh — удаление осиротевших root-демонов и согласованных приложений.
#
# ⚠️ ОДНОРАЗОВЫЙ СКРИПТ-СНИМОК (2026-08-31). Список целей собран вручную под
# состояние этой машины на эту дату (каждая цель проверена: приложения-владельца
# нет на диске). НЕ запускать на других машинах и не переиспользовать позже без
# новой ревизии — установленный заново софт может совпасть по путям.
#
# Все пункты одобрены владельцем поимённо 2026-08-31 (docs/decisions.md).
# Запуск:  sudo bash scripts/cleanup_root.sh
# Мелкие plist'ы/хелперы бэкапятся в ~/MacTweaksBackup-2026-08-31/root/,
# крупные бандлы (приложения, фреймворки) удаляются без бэкапа — они
# переустанавливаются штатными инсталляторами с сайтов производителей.

set -u
[ "$(id -u)" -eq 0 ] || { echo "Запусти через sudo: sudo bash $0"; exit 1; }

USER_HOME=$(eval echo "~${SUDO_USER:-$(stat -f%Su /dev/console)}")
BK="$USER_HOME/MacTweaksBackup-2026-08-31/root"
mkdir -p "$BK"

bk_rm() { # бэкап + удаление (для мелких файлов)
  for p in "$@"; do
    [ -e "$p" ] || continue
    ditto "$p" "$BK/$(basename "$p")" 2>/dev/null
    rm -rf "$p" && echo "  ✕ $p (бэкап сделан)"
  done
}
just_rm() { # удаление без бэкапа (крупные бандлы)
  for p in "$@"; do
    [ -e "$p" ] || continue
    rm -rf "$p" && echo "  ✕ $p"
  done
}
unload() { launchctl bootout "system/$1" 2>/dev/null && echo "  ⏹ выгружен $1"; return 0; }

echo "═══ 1/13 Turbo Boost Switcher (Intel-only, приложение удалено) ═══"
bk_rm /Library/PrivilegedHelperTools/com.rugarciap.TurboBoost260Helper

echo "═══ 2/13 Macs Fan Control (Air M4 безвентиляторный) ═══"
bk_rm /Library/PrivilegedHelperTools/com.crystalidea.macsfancontrol.smcwrite

echo "═══ 3/13 cDock Injector (x86, не работает при SIP) ═══"
bk_rm /Library/PrivilegedHelperTools/com.macenhance.cDock.Injector

echo "═══ 4/13 GOG Galaxy ClientService ═══"
unload com.gog.galaxy.ClientService
bk_rm /Library/LaunchDaemons/com.gog.galaxy.ClientService.plist \
      /Library/PrivilegedHelperTools/com.gog.galaxy.ClientService

echo "═══ 5/13 Kairos awdltool ═══"
unload com.kairos.awdltool.xpc
bk_rm /Library/LaunchDaemons/com.kairos.awdltool.xpc.plist \
      /Library/PrivilegedHelperTools/com.kairos.awdltool.xpc

echo "═══ 6/13 CleanMyMac 4 Agent ═══"
bk_rm /Library/PrivilegedHelperTools/com.macpaw.CleanMyMac4.Agent

echo "═══ 7/13 OpenVPN Connect (заменён Amnezia/Outline) ═══"
unload org.openvpn.client
unload org.openvpn.helper
bk_rm /Library/LaunchDaemons/org.openvpn.client.plist \
      /Library/LaunchDaemons/org.openvpn.helper.plist
just_rm /Library/Frameworks/OpenVPNConnect.framework \
        /Library/Frameworks/OVPNHelper.framework

echo "═══ 8/13 Fresco Logic FL2000 (адаптер продан) ═══"
unload com.frescologic.fl2000_daemon
bk_rm /Library/LaunchDaemons/com.frescologic.fl2000_daemon.plist \
      /Library/LaunchAgents/com.frescologic.fl2000_display.plist \
      /Library/LaunchAgents/com.frescologic.fl2000_display-prelogin.plist \
      /usr/local/libexec/fl2000_daemon \
      /usr/local/libexec/fl2000_display

echo "═══ 9/13 DisplayLink (адаптер продан; драйвер свободно доступен на synaptics.com) ═══"
pkill -f DisplayLinkUserAgent 2>/dev/null
pkill -f DisplayLinkXpcService 2>/dev/null
bk_rm /Library/LaunchAgents/com.displaylink.loginscreen.plist
just_rm "/Applications/DisplayLink Manager.app"

echo "═══ 10/13 Rogue Amoeba ACE (Loopback удалён) ═══"
unload com.rogueamoeba.aceagent.label
unload com.rogueamoeba.acetool.label
bk_rm /Library/LaunchDaemons/com.rogueamoeba.aceagent.plist \
      /Library/LaunchDaemons/com.rogueamoeba.acetool.plist \
      "/Library/Audio/Plug-Ins/HAL/ACE.driver"

echo "═══ 11/13 TeamViewer (штатный деинсталлятор, с настройками) ═══"
TV_UNINST="/Library/Application Support/TeamViewer/TeamViewerUninstaller.app/Contents/Helpers/UninstallTeamViewer"
if [ -x "$TV_UNINST" ]; then
  "$TV_UNINST" --force --delete-settings && echo "  ✕ TeamViewer удалён штатно"
else
  unload com.teamviewer.Helper
  unload com.teamviewer.UninstallerHelper
  unload com.teamviewer.UninstallerWatcher
  bk_rm /Library/LaunchDaemons/com.teamviewer.Helper.plist \
        /Library/LaunchDaemons/com.teamviewer.UninstallerHelper.plist \
        /Library/LaunchDaemons/com.teamviewer.UninstallerWatcher.plist \
        /Library/PrivilegedHelperTools/com.teamviewer.Helper \
        /Library/PrivilegedHelperTools/com.teamviewer.UninstallerHelper
  just_rm /Applications/TeamViewer.app "/Library/Application Support/TeamViewer"
fi

echo "═══ 12/13 Хвосты: Photoshop 2025 + старый janitor-демон v1 ═══"
just_rm "/Applications/Adobe Photoshop 2025"
unload com.user.cleaner
bk_rm /Library/LaunchDaemons/com.user.cleaner.plist

echo "═══ 13/13 SwitchResX helper (приложение удалено) ═══"
unload fr.madrau.switchresx.helper
bk_rm /Library/LaunchDaemons/fr.madrau.switchresx.helper.plist \
      /Library/PrivilegedHelperTools/fr.madrau.switchresx.helper

echo
echo "✅ Root-чистка завершена. Бэкапы: $BK"
echo "   Рекомендуется перезагрузка."
