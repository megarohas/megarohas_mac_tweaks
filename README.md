# megarohas_mac_tweaks

**English** | [Русский](README.ru.md)

Audit and optimization of a MacBook Air (M4, 16 GB, macOS 27 beta): sorting out
startup items, orphaned root daemons, the database dev stack and the disk. Third
project in the series — after the router and the Android TV box
(megarohas_android_tv_tweaks).

> ⚠️ **This is a one-off snapshot, not a universal recipe.** The `cleanup_*`
> scripts and switching services to manual start reflect the state of **one
> specific machine** and its owner's decisions **as of 2026-08-31**. They're not
> meant to be re-run "on a schedule", let alone on other Macs. Everything is
> reversible and may go stale: if you need Redis to start at login again, run
> `brew services start redis` — that doesn't contradict this repo. The only
> reusable parts here are `audit.sh`, `dev.sh` and the approach itself; regular
> cleanup is handled by a separate project,
> [macos_janitor](https://github.com/megarohas/macos_janitor).

## Before and after

- **Swap at 5.7/6 GB** → five always-on database servers cut down to the two that
  are actually needed: MySQL/Redis/RabbitMQ switched to manual start
  (`dev up/down`), PostgreSQL and MongoDB kept at the owner's call.
- **12+ startup items left behind by uninstalled apps** (down to a fan controller
  on a fanless Air) — removed, with backups.
- **The nightly cleaner**, which had been failing silently for over a year after
  its folder was moved — rewritten and working again:
  [macos_janitor](https://github.com/megarohas/macos_janitor).
- **Disk**: 6–8 GB of junk removed (caches, leftovers of uninstalled apps, video
  wallpapers), 79 brew formulae upgraded, mysql pinned for the sake of dormant
  data directories.

Full story: [docs/audit-2026-08-31.md](docs/audit-2026-08-31.md) (in Russian) ·
all decisions: [docs/decisions.md](docs/decisions.md) (in Russian)

## Scripts

| Script | What it does | How to run |
|---|---|---|
| `scripts/audit.sh` | Read-only system snapshot (startup items, memory, top processes, disk) | `bash scripts/audit.sh` |
| `scripts/dev.sh` | Dev stack on demand: `dev up`, `dev down`, `dev status` | alias in `.zshrc` |
| `scripts/cleanup_user.sh` | User-level cleanup (caches, app leftovers, databases approved for removal) | `bash scripts/cleanup_user.sh` |
| `scripts/cleanup_root.sh` | Removes orphaned daemons/apps, with backups | `sudo bash scripts/cleanup_root.sh` |

Order for the first run: `cleanup_user.sh` → `sudo cleanup_root.sh` →
reboot → a final `audit.sh` to verify.

## Principles

1. **Recon first, hands second**: every daemon gets checked — does the owning
   app still exist, what architecture is the binary, who's holding the ports.
2. **Every removal is approved individually** — no batch "optimizations".
3. **Everything is reversible**: plists and helpers are backed up, databases are
   dumped before removal.
4. **Backups and dumps never go into git** — the repo holds only scripts and docs.
5. Nothing that works and is in use gets touched, even if "it'd be better that
   way".
