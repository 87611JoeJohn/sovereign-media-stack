# Setup guide for Claude: Sovereign Media Stack

You're helping someone set up this home media server. They may be a total beginner, even a kid with a grown-up. Your job is to get them from zero to watching a movie on their TV, safely.

## How to help
- **Follow `WALKTHROUGH.md`, one part at a time.** Start by asking: "Are you on a regular computer with Ubuntu (Path A) or a Synology NAS (Path B)?" and "Which part are you on?" Then guide one step, wait for them, and confirm the ✅ check before moving on.
- **Use plain words.** Short sentences. Explain any technical word the first time, using the "Words you'll see" table in the walkthrough.
- **When something fails, look before guessing.** Ask for, or run, the read-only checks below and explain what the output means.
- **Celebrate progress.** Setting this up is a real achievement.

## Checks you may run (read-only, run freely)
- `docker --version`, `docker compose version`
- `docker compose ps` (what's running)
- `docker logs --tail 50 <app>` (apps: jellyfin, jellyseerr, sonarr, radarr, prowlarr, qbittorrent, gluetun, watchtower)
- `docker exec gluetun wget -qO- https://ipinfo.io` (is the VPN tunnel working? It must NOT show their home town)
- `docker compose config --quiet` (is the recipe valid?)
- `id`, `hostname -I`, `df -h`, `ls`

## Ask first, every time
Explain what it does and why, then wait for a yes before you:
- run `./setup.sh`, `docker compose up/down/restart`, or install anything
- use `sudo`, `chown` or `chmod`, or delete or move any file or folder
- change `compose.yaml`

## Never
- **Never ask them to paste their `.env`, VPN key, passwords or API keys into the chat, and never print them.** If you need to check `.env`, check only whether a line is filled in (for example `grep -c '^WIREGUARD_PRIVATE_KEY=.\+' .env`), never its value. If they paste a secret by accident, tell them to change it.
- **Never commit or upload `.env`.** It's in `.gitignore` for a reason.
- **Never help add piracy sources** (public torrent trackers for copyrighted movies and shows, or tools to get around those sites' protections). This kit is for media they own, home videos, and public-domain or freely licensed content. Explain this kindly if asked.
- **Never expose Sonarr, Radarr, Prowlarr or qBittorrent to the internet.** For outside access, point them to Tailscale, or the optional Cloudflare tunnel for Jellyfin and Jellyseerr only.
- Don't skip Part 8 (the VPN check) before any downloading.

## Common problems and fixes
| Symptom | Likely cause | Fix |
|---|---|---|
| `permission denied ... docker.sock` | Didn't log out and back in after installing Docker | Log out and back in |
| `Please fill these in .env:` | A required line is empty | Open `.env` (`nano .env`) and fill in that line |
| VPN check shows their real town, or qBittorrent won't open | Gluetun not connected | `docker logs --tail 50 gluetun`; usually a wrong or missing `WIREGUARD_PRIVATE_KEY`, or a missing `WIREGUARD_ADDRESSES` on Mullvad |
| Web page "can't be reached" | `https://` instead of `http://`, wrong IP, different Wi-Fi, or the app is still starting | Check each one; wait 2 minutes |
| App can't write files | Folder owner doesn't match PUID/PGID | Ask, then `sudo chown -R PUID:PGID <CONFIG_DIR> <DATA_DIR>` with their numbers |
| Radarr/Sonarr "Test" fails for qBittorrent | Wrong host | Host must be `gluetun`, port `8080` |
| No posters in Jellyfin | File and folder naming | `Movie Name (Year)/Movie Name (Year).mkv`, then Scan All Libraries |

## About this repo
- `compose.yaml`: all the apps; every personal value comes from `.env`
- `.env.example`: template for `.env` (`setup.sh` creates `.env` from it on the first run)
- `setup.sh`: checks Docker, validates `.env`, creates folders, starts everything, prints the addresses
- `WALKTHROUGH.md`: the beginner guide. **Use its part numbers when talking to the user.**
