#!/usr/bin/env bash
# One-step setup for the home media stack. Safe to run again.
set -euo pipefail
cd "$(dirname "$0")"

command -v docker >/dev/null || { echo "Docker isn't installed. Install Docker first: https://docs.docker.com/engine/install/"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "Docker Compose v2 is missing (the 'docker compose' command)."; exit 1; }

if [ ! -f .env ]; then
  cp .env.example .env
  chmod 600 .env   # only you can read your secrets
  echo "Created .env from the example. Open it, fill in your folders, user ids, timezone and VPN details, then run ./setup.sh again."
  exit 0
fi
chmod 600 .env 2>/dev/null || true
set -a; . ./.env; set +a

missing=()
for v in CONFIG_DIR DATA_DIR PUID PGID TZ VPN_SERVICE_PROVIDER VPN_TYPE; do [ -n "${!v:-}" ] || missing+=("$v"); done
if [ "$VPN_TYPE" = wireguard ] && [ -z "${WIREGUARD_PRIVATE_KEY:-}" ]; then missing+=(WIREGUARD_PRIVATE_KEY); fi
if [ "$VPN_TYPE" = openvpn ] && { [ -z "${OPENVPN_USER:-}" ] || [ -z "${OPENVPN_PASSWORD:-}" ]; }; then missing+=(OPENVPN_USER/OPENVPN_PASSWORD); fi
[ ${#missing[@]} -eq 0 ] || { echo "Please fill these in .env: ${missing[*]}"; exit 1; }

echo "Creating folders..."
for d in jellyfin jellyseerr sonarr radarr prowlarr qbittorrent gluetun; do mkdir -p "$CONFIG_DIR/$d"; done
mkdir -p "$DATA_DIR/media/movies" "$DATA_DIR/media/tv" "$DATA_DIR/media/music" "$DATA_DIR/downloads"
chown -R "$PUID:$PGID" "$CONFIG_DIR" "$DATA_DIR" 2>/dev/null || echo "(Couldn't change folder owner; if apps can't write, run: sudo chown -R $PUID:$PGID $CONFIG_DIR $DATA_DIR)"

profiles=()
[ -n "${CLOUDFLARE_TUNNEL_TOKEN:-}" ] && profiles=(--profile remote)
docker compose "${profiles[@]}" up -d

ip=$(hostname -I 2>/dev/null | awk '{print $1}'); ip=${ip:-localhost}
cat <<MSG

All started. Open these on any device on your network:
  Jellyfin     http://$ip:8096   (watch; do its setup wizard first)
  Jellyseerr   http://$ip:5055   (requests; sign in with your Jellyfin account)
  Sonarr       http://$ip:8989   (TV)
  Radarr       http://$ip:7878   (movies)
  Prowlarr     http://$ip:9696   (sources)
  qBittorrent  http://$ip:8080   (downloads; temporary password: docker logs qbittorrent)

Check the VPN is working:  docker exec gluetun wget -qO- https://ipinfo.io
Step-by-step help: WALKTHROUGH.md
MSG
