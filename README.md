# Sovereign Media Stack

**👉 New to this? Start with [WALKTHROUGH.md](WALKTHROUGH.md): a click-by-click guide anyone can follow.**

Your own streaming service at home: watch on every TV and phone, let the family request things, and keep your library organized. Everything runs on your own computer or NAS with Docker. No subscription.

| App | What it does | Address |
|---|---|---|
| **Jellyfin** | Your streaming service: movies, shows and music on every screen | `:8096` |
| **Jellyseerr** | A simple "request a movie or show" page for the family | `:5055` |
| **Sonarr** | Organizes your TV library and watches for new episodes | `:8989` |
| **Radarr** | Organizes your movie library | `:7878` |
| **Prowlarr** | One place to manage your download sources | `:9696` |
| **qBittorrent + Gluetun** | Download client that can only reach the internet through your VPN | `:8080` |
| **Watchtower** | Updates the apps once a week (never Jellyfin, which you upgrade on purpose) | — |
| **Cloudflared** *(optional)* | Reach Jellyfin from outside your home without opening router ports | — |

## What you need
- A Linux machine or NAS that runs Docker (Synology, Unraid, Ubuntu, etc.)
- Plenty of storage for your media
- A VPN subscription that works with [Gluetun](https://github.com/qdm12/gluetun-wiki) (only for the download client)

## Setup

New to this? Follow [WALKTHROUGH.md](WALKTHROUGH.md), the click-by-click guide.

1. Copy this folder to the machine.
2. Run `./setup.sh`. The first time, it creates `.env` and stops.
3. Open `.env` and fill it in: folders, your user ids (`id` shows them), timezone, VPN details.
4. Run `./setup.sh` again. It creates the folders, starts everything and prints the addresses.

## First-run checklist
1. **Jellyfin** (`:8096`): run the wizard, create your admin account, add libraries pointing at `/data/media/movies`, `/data/media/tv` and `/data/media/music`.
2. **qBittorrent** (`:8080`): log in with the temporary password from `docker logs qbittorrent`, then change it. Set the save folder to `/data/downloads`.
3. **Check the VPN**: `docker exec gluetun wget -qO- https://ipinfo.io` should show your VPN's location, not your home.
4. **Radarr** and **Sonarr**: Settings → Media Management → root folder `/data/media/movies` (Radarr) or `/data/media/tv` (Sonarr). Settings → Download Clients → add qBittorrent with host `gluetun`, port `8080`.
5. **Prowlarr**: add the download sources you're allowed to use, then Settings → Apps → add Sonarr and Radarr so they share those sources.
6. **Jellyseerr** (`:5055`): sign in with your Jellyfin account, then connect it to Radarr and Sonarr.
7. **Jellyfin apps**: install Jellyfin on your TVs and phones and point them at `http://<server-ip>:8096`. On home Wi-Fi this works even when the internet is down.

## Good habits (learned the hard way)
- **Keep secrets in `.env` only.** Never put passwords, VPN keys or tunnel tokens in `compose.yaml`, and never share or upload `.env`.
- **Upgrade Jellyfin on purpose.** It's pinned with `JELLYFIN_VERSION` and left out of Watchtower, because a major automatic update once left a server crash-looping.
- **Don't expose Sonarr, Radarr, Prowlarr or qBittorrent to the internet.** If you want outside access, use the optional Cloudflare tunnel for Jellyfin and Jellyseerr only, or a private VPN like Tailscale.
- **Watchtower can control Docker** (it needs that to update apps). Only run images you trust, and remove Watchtower if you'd rather update by hand.
- **Back up `CONFIG_DIR`.** It's small and holds all your settings. Your media is in `DATA_DIR`.
- **One shared `/data` folder** lets Sonarr and Radarr move finished downloads instantly instead of copying them.

## Use it legally
This template comes with **no download sources** configured. You're responsible for what you add. Use it for media you own, home videos, public-domain and freely licensed content, and sources you have the right to use. Downloading copyrighted movies and shows without permission is illegal in most countries, and a VPN doesn't change that.
