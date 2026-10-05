# 🏠 Build Your Own Streaming Service at Home
### The super-easy, step-by-step guide (yes, a 10-year-old can do this!)

Hi! 👋 By the end of this guide you'll have **your own Netflix-style app** that plays your movies and shows on every TV, phone and tablet in your house. Nobody else runs it. It's **yours**.

**How to use this guide:**
- Do the parts **in order**. Don't skip ahead.
- Each step has a ✅ **Check** that tells you what you should see. If you see it, go on. If you don't, look at 🆘 **Help!** at the end.
- Text in a gray box like `this` is something you **type exactly**, letter for letter. The easiest way is to **copy and paste** it.
- 🧑‍🧒 means **ask a grown-up**. Those steps need a password, a credit card, or permission.

⏱️ **Time needed:** about 1 to 2 hours. Take breaks! Your progress is saved.

---

## 📖 Part 0: Words you'll see

You don't need to memorize these. Come back here whenever a word is confusing.

| Word | What it means | Think of it like... |
|---|---|---|
| **Server** | The computer that stays on and runs everything | The kitchen in a restaurant |
| **Docker** | A program that runs each app in its own neat box | Lunchboxes: each app has its own, so nothing gets mixed up |
| **Container** | One of those boxes with one app inside | One lunchbox |
| **Terminal** | A window where you type commands instead of clicking | Texting the computer what to do |
| **IP address** | Your server's address on your home Wi-Fi, like `192.168.1.50` | A house number on your street |
| **Port** | The number after the `:` in an address, like `:8096` | Which door of the house to knock on |
| **VPN** | A private, scrambled tunnel to the internet | A secret tunnel nobody can see into |
| **.env file** | Your secret settings file | Your diary with a lock 🔒 |
| **Folder / path** | Where files live, like `/srv/media` | Rooms and shelves in a house |

**The apps you're installing:**

| App | Its job | Like... |
|---|---|---|
| 📺 **Jellyfin** | Plays your movies and shows on every screen | The TV channel |
| 🙋 **Jellyseerr** | Family members ask for movies and shows | The wish list on the fridge |
| 📚 **Sonarr** | Keeps your TV shows sorted and named nicely | The TV-show librarian |
| 🎬 **Radarr** | Keeps your movies sorted and named nicely | The movie librarian |
| 🔎 **Prowlarr** | Remembers where downloads come from | The phone book |
| 📦 **qBittorrent** | Downloads files | The delivery truck |
| 🚇 **Gluetun** | Makes the truck use the VPN tunnel only | The tunnel the truck must drive through |
| 🔄 **Watchtower** | Updates the apps once a week | The helper who keeps everything fresh |

---

## 🧰 Part 1: What you need

Check off each one before you start:

- [ ] **A computer that can stay on all the time.** Pick ONE:
  - **Path A:** a regular computer or old laptop with **Ubuntu** (free) on it. 👉 If you're not sure, use this one.
  - **Path B:** a **Synology NAS** (a storage box from the company Synology).
- [ ] **A big hard drive** (2 TB or more) for movies. It can be inside the computer or plugged in by USB.
- [ ] 🧑‍🧒 **A VPN account** that works with Gluetun. Good choices: **ProtonVPN** or **Mullvad**. This costs a little money each month.
- [ ] **The computer is plugged into your home internet** (a cable is best, Wi-Fi is OK).
- [ ] **Another device to test with**, like a phone or TV on the same Wi-Fi.

> 💡 This guide shows **Path A (Ubuntu)** first. Synology owners: look for the 🟦 **Path B** boxes.

---

## 🐳 Part 2: Install Docker

### Path A: Ubuntu

**Step 2.1: Open the Terminal.**
Press these three keys at the same time: `Ctrl` + `Alt` + `T`.
A black or purple window opens with a blinking line. That's the Terminal!

**Step 2.2: Install Docker.**
Copy this line, paste it into the Terminal (right-click → **Paste**), and press `Enter`:

```
curl -fsSL https://get.docker.com | sudo sh
```

🧑‍🧒 It asks for **your computer password**. Type it and press `Enter`.
😮 **You won't see any dots or letters while you type. That's normal!** It's hiding your password.

Wait 1 to 5 minutes while lots of text scrolls by. ☕ When the blinking line comes back, it's done.

**Step 2.3: Let yourself use Docker.**
Copy, paste, `Enter`:

```
sudo usermod -aG docker $USER
```

**Step 2.4: Log out and log back in.**
Click the power icon (top right) → **Log Out**, then log in again. (Restarting the computer works too.)
This step is **important**. Docker won't listen to you until you do it.

✅ **Check:** open the Terminal again (`Ctrl` + `Alt` + `T`) and type:

```
docker --version
```

You should see something like `Docker version 27.3.1`. 🎉

### 🟦 Path B: Synology NAS
1. Open your NAS in a web browser (the address you normally use, like `http://192.168.1.20:5000`) and log in.
2. Open **Package Center**.
3. Search for **Container Manager** → **Install**.
4. Also install **Text Editor** from Package Center. You'll need it in Part 5.

✅ **Check:** **Container Manager** now shows in the main menu.

---

## 📥 Part 3: Get the kit

### Path A: Ubuntu
**Step 3.1:** in the Terminal, copy, paste, `Enter` (one line at a time):

```
sudo apt install -y git
git clone https://github.com/87611JoeJohn/sovereign-media-stack.git
cd sovereign-media-stack
```

✅ **Check:** type `ls` and press `Enter`. You should see these names:

```
README.md  WALKTHROUGH.md  compose.yaml  setup.sh
```

> 📌 **Remember:** whenever this guide says "go to the kit folder", type `cd ~/sovereign-media-stack` in the Terminal.

### 🟦 Path B: Synology
1. On any computer, open `https://github.com/87611JoeJohn/sovereign-media-stack`
2. Click the green **Code** button → **Download ZIP**. Unzip it.
3. On the NAS, open **File Station** → open the **docker** folder (make it if it's missing) → **Create folder** → name it `sovereign-media-stack`.
4. Open that new folder → **Upload** → upload every file from the unzipped kit, including `.env.example`.

> 💡 Files starting with a dot (like `.env.example`) can be hidden on your computer. On Windows: File Explorer → **View** → tick **Hidden items**. On Mac: press `Cmd` + `Shift` + `.` in the folder.

---

## 🔢 Part 4: Find your numbers

You need four things. Write them on paper as you find them. 📝

### 4.1 Your user numbers (PUID and PGID)

**Path A:** in the Terminal type:

```
id
```

You'll see something like:
`uid=1000(sam) gid=1000(sam) groups=...`

- The number after `uid=` is your **PUID**. Here it's `1000`.
- The number after `gid=` is your **PGID**. Here it's `1000`.

🟦 **Path B (Synology):** most Synology accounts are PUID `1026` and PGID `100`. To be sure, ask a grown-up to check **Control Panel → User & Group**, or log in by SSH and type `id`.

### 4.2 Your time zone
Find yours in this list: <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>. Look at the **"TZ identifier"** column.
Examples: `America/New_York`, `America/Chicago`, `America/Denver`, `America/Los_Angeles`, `Europe/London`.

### 4.3 Where things will live (two folders)
- **CONFIG_DIR**: where app settings go. Small. Example: `/srv/mediastack/config`
- **DATA_DIR**: where movies go. Big! Put it on your big drive. Example: `/srv/mediastack/data`

**Path A, not sure where your big drive is?** Type `df -h` in the Terminal. Look at the **Size** column for your big drive, and use the folder in the **Mounted on** column (like `/mnt/bigdrive`). Then use `/mnt/bigdrive/mediastack/data` as your DATA_DIR.

🟦 **Path B (Synology):** use `/volume1/docker/sovereign-media-stack/config` and `/volume1/docker/sovereign-media-stack/data`.

### 4.4 Your server's IP address
**Path A:** type:

```
hostname -I
```

The first number, like `192.168.1.50`, is your server's address. 📝 Write it down!

🟦 **Path B:** it's the number in your browser's address bar when you open the NAS, without the `:5000` part.

---

## 🔑 Part 5: Get your VPN key 🧑‍🧒

The download truck must only drive through the secret tunnel. For that you need a **key** from your VPN company.

### If you use ProtonVPN
1. Go to <https://account.protonvpn.com> and log in.
2. On the left, click **Downloads**.
3. Scroll down to **WireGuard configuration**.
4. **Device name:** type `media-server`.
5. **Platform:** choose **Linux** (or **Router**).
6. Choose a country and server near you → click **Create**.
7. A box shows a text file. Find the line that starts with `PrivateKey = `.
8. Copy **only the long jumble after** `PrivateKey = `. It ends with `=`.
9. 📝 Save it somewhere safe. **Don't share it with anyone!**

### If you use Mullvad
1. Go to <https://mullvad.net/account> and log in.
2. Click **WireGuard configuration** → **Linux** → **Generate key**.
3. Choose a country → **Download file**. Open the file with a text editor.
4. Copy the jumble after `PrivateKey = ` (that's your key).
5. Also copy the text after `Address = `, like `10.64.222.21/32`. Mullvad needs this too.

---

## ✍️ Part 6: Fill in your secret settings

### Path A: Ubuntu
**Step 6.1:** go to the kit folder and run the setup for the first time:

```
cd ~/sovereign-media-stack
./setup.sh
```

✅ **Check:** you see `Created .env from the example...`

**Step 6.2:** open your secret settings file:

```
nano .env
```

A text editor opens **inside** the Terminal.
🖱️ The mouse doesn't work here! Use the **arrow keys** ⬆️⬇️⬅️➡️ to move around.

**Step 6.3:** change each line using the numbers from your paper. Delete the example after the `=` and type yours. **No spaces around the `=`!**

| Line | Put in... | Example |
|---|---|---|
| `CONFIG_DIR=` | Part 4.3 | `/srv/mediastack/config` |
| `DATA_DIR=` | Part 4.3 | `/mnt/bigdrive/mediastack/data` |
| `PUID=` | Part 4.1 | `1000` |
| `PGID=` | Part 4.1 | `1000` |
| `TZ=` | Part 4.2 | `America/Chicago` |
| `VPN_SERVICE_PROVIDER=` | `protonvpn` or `mullvad` | `protonvpn` |
| `VPN_TYPE=` | leave it as `wireguard` | `wireguard` |
| `WIREGUARD_PRIVATE_KEY=` | your key from Part 5 | `yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=` *(example, not real)* |
| `WIREGUARD_ADDRESSES=` | Mullvad only; leave empty for ProtonVPN | `10.64.222.21/32` |
| `VPN_SERVER_COUNTRIES=` | the country you picked, in quotes | `"United States"` |

Leave `OPENVPN_USER`, `OPENVPN_PASSWORD`, `CLOUDFLARE_TUNNEL_TOKEN` and `JELLYFIN_VERSION` as they are.

**Step 6.4: save and close.**
1. Press `Ctrl` + `O` (the letter O). At the bottom it says `File Name to Write: .env`.
2. Press `Enter` to save.
3. Press `Ctrl` + `X` to leave.

### 🟦 Path B: Synology
1. In **File Station**, open the `sovereign-media-stack` folder.
2. Right-click `.env.example` → **Copy**, then paste it in the same folder and rename the copy to `.env`.
3. Right-click `.env` → **Open with Text Editor**.
4. Fill it in using the table above → **File → Save**.
5. In File Station, create these folders inside `sovereign-media-stack`:
   `config`, and `data` with `data/media/movies`, `data/media/tv`, `data/media/music` and `data/downloads` inside it.

---

## 🚀 Part 7: Start everything!

### Path A: Ubuntu
In the kit folder, type:

```
./setup.sh
```

It downloads all the apps. ⏳ The first time takes **5 to 15 minutes**. Lots of lines with `Pulling` and `Started` scroll past. That's good!

✅ **Check:** at the end you see a list like this, with **your** address:

```
All started. Open these on any device on your network:
  Jellyfin     http://192.168.1.50:8096
  Jellyseerr   http://192.168.1.50:5055
  Sonarr       http://192.168.1.50:8989
  Radarr       http://192.168.1.50:7878
  Prowlarr     http://192.168.1.50:9696
  qBittorrent  http://192.168.1.50:8080
```

📸 Take a photo of this list or write it down!

If it says **`Please fill these in .env:`** followed by a name, go back to Part 6 and fill in that line.

### 🟦 Path B: Synology
1. Open **Container Manager** → **Project** → **Create**.
2. **Project name:** `sovereign-media-stack`
3. **Path:** click **Set Path** → choose the `docker/sovereign-media-stack` folder.
4. It says it found `compose.yaml`. Choose **Use existing**.
5. Click **Next** → **Next** → **Done**. ⏳ Wait 5 to 15 minutes.

✅ **Check:** **Container Manager → Container** shows 8 apps, each with a green dot.

---

## 🛡️ Part 8: Check the secret tunnel (very important!)

Before downloading **anything**, make sure the truck is really in the tunnel.

**Path A:** type:

```
docker exec gluetun wget -qO- https://ipinfo.io
```

✅ **Check:** look at the `"city"` and `"country"` lines.
- It shows the **VPN's country or city** (like the one you picked in Part 5)? 🎉 Perfect!
- It shows **your real town**? 🛑 **STOP.** Something's wrong with the VPN. See 🆘 **Help!**

🟦 **Path B:** Container Manager → **Container** → **gluetun** → **Log**. Look for a line with **`Public IP address is`** and a country. It should be the VPN's country, not yours.

---

## 🎛️ Part 9: Set up each app

Now use any computer or phone **on the same Wi-Fi**. Open a web browser and type each address. Use **your** server address from Part 4.4 instead of `YOUR-ADDRESS`.

> ⚠️ Type `http://`, **not** `https://`. These apps live at home, and `https` won't work.

### 📺 9.1 Jellyfin: `http://YOUR-ADDRESS:8096`
1. **Welcome!** → choose your language → **Next**.
2. **Username:** pick one (like `mom` or `sam`). **Password:** make a good one. 📝 Write it down. → **Next**.
3. **Add Media Library** (the big ➕):
   - **Content type:** **Movies**
   - **Display name:** `Movies`
   - **Folders** ➕ → type `/data/media/movies` → **OK**
   - Click **OK** at the bottom.
4. ➕ again for shows: **Content type: Shows**, name `TV Shows`, folder `/data/media/tv`.
5. ➕ again for music: **Content type: Music**, name `Music`, folder `/data/media/music`.
6. Click **Next** until you see **Finish**. Click **Finish**.
7. Log in with your new username and password.

✅ **Check:** you see the Jellyfin home screen with your libraries (empty for now).

### 📦 9.2 qBittorrent: `http://YOUR-ADDRESS:8080`
1. **Find the first password.** Path A: in the Terminal type:
   ```
   docker logs qbittorrent
   ```
   Look for the line `A temporary password is provided for this session:` and copy the password after it.
   🟦 Path B: Container Manager → Container → **qbittorrent** → **Log**, and find the same line.
2. Log in. Username: `admin`. Password: the one you just found.
3. Click the ⚙️ gear (**Options**) → **WebUI** tab → under **Authentication**, type a new password. 📝 Write it down. → **Save**.
4. ⚙️ again → **Downloads** tab → **Default Save Path:** `/data/downloads` → **Save**.

### 🎬 9.3 Radarr (movies): `http://YOUR-ADDRESS:7878`
1. It asks you to set up a login. **Authentication Method:** **Forms (Login Page)**. Make a username and password. 📝 → **Save**.
2. Left side: **Settings** → **Media Management** → scroll down → **Add Root Folder** → type `/data/media/movies` → click the ✓.
3. **Settings** → **Download Clients** → big ➕ → click **qBittorrent**. Fill in:
   - **Host:** `gluetun` (yes, gluetun, because that's the tunnel the truck lives in!)
   - **Port:** `8080`
   - **Username:** `admin`
   - **Password:** your qBittorrent password from 9.2
4. Click **Test**. ✅ A green check ✔️ appears. → **Save**.
5. **Settings** → **General** → copy the **API Key** (a long code). 📝 You'll need it soon.

### 📺 9.4 Sonarr (TV shows): `http://YOUR-ADDRESS:8989`
Do **exactly** the same as Radarr (9.3), but in step 2 use the folder `/data/media/tv`. Copy Sonarr's **API Key** too. 📝

### 🔎 9.5 Prowlarr (sources): `http://YOUR-ADDRESS:9696`
1. Set up a login like before. 📝
2. **Settings** → **Apps** → ➕ → **Radarr**:
   - **Prowlarr Server:** `http://prowlarr:9696`
   - **Radarr Server:** `http://radarr:7878`
   - **API Key:** Radarr's key from 9.3
   - **Test** ✔️ → **Save**
3. ➕ again → **Sonarr**: **Sonarr Server** `http://sonarr:8989`, with Sonarr's key → **Test** ✔️ → **Save**.
4. **Indexers** → ➕: add **only sources you're allowed to use.** See Part 11. 🧑‍🧒

### 🙋 9.6 Jellyseerr (wish list): `http://YOUR-ADDRESS:5055`
1. Click **Use your Jellyfin account**.
2. **Jellyfin URL:** `http://jellyfin:8096` → your Jellyfin username and password → **Sign In**.
3. Click **Sync Libraries** → tick **Movies** and **TV Shows** → **Continue**.
4. **Add Radarr Server:**
   - **Default Server:** ✔️ ticked
   - **Server Name:** `Radarr`
   - **Hostname:** `radarr`
   - **Port:** `7878`
   - **API Key:** Radarr's key
   - Click **Test**. Then pick **Quality Profile:** `Any` and **Root Folder:** `/data/media/movies` → **Add Server**
5. **Add Sonarr Server**: same idea with hostname `sonarr`, port `8989`, Sonarr's key, root folder `/data/media/tv` → **Add Server**.
6. **Finish Setup**. 🎉

---

## 📺 Part 10: Watch on your TV and phone

1. On your TV, open its app store (Google TV, Fire TV, Roku, LG, Samsung, Apple TV) and search **Jellyfin** → **Install**.
2. Open it. When it asks for a **server**, type: `http://YOUR-ADDRESS:8096`
3. Log in with your Jellyfin username and password.
4. Do the same on phones and tablets (the app is called **Jellyfin**).

**Add your first movie:** put a movie file you own into the `movies` folder (`DATA_DIR/media/movies`). Give it its own folder named like `Movie Name (2010)`. Then in Jellyfin: ☰ menu → **Dashboard** → **Libraries** → **Scan All Libraries**. A poster appears! 🍿

✅ **Check:** you can play a movie on the TV. **YOU DID IT!** 🎉🎉🎉

---

## ⚖️ Part 11: Play by the rules 🧑‍🧒

This kit comes with **no download sources**. Use it for:
- ✅ movies and music **you bought** (DVDs you own count only if they don't have copy protection; most store DVDs do)
- ✅ **your own** home videos and photos
- ✅ **free and public-domain** films. There are thousands, like the Internet Archive's collection.

🚫 Downloading movies and shows you didn't pay for is **against the law** in most countries, **even with a VPN**. The VPN keeps you private. It doesn't make anything legal.

---

## 🔒 Part 12: Keep it safe

- 🤐 **Never share your `.env` file.** It has your VPN key. Don't post it, email it, or upload it anywhere.
- 🏠 **Keep the helper apps at home.** Sonarr, Radarr, Prowlarr and qBittorrent should never be opened to the internet.
- 🔑 **Use different passwords** for each app, and keep them in a password manager.
- 💾 **Back up the `config` folder** now and then (copy it to a USB drive). It holds all your settings.
- 🧑‍🧒 **Watching away from home?** The safest way is **Tailscale** (free for personal use). Ask a grown-up to set it up.

---

## 🔁 Part 13: Everyday commands (Path A)

Always go to the kit folder first: `cd ~/sovereign-media-stack`

| I want to... | Type this |
|---|---|
| See what's running | `docker compose ps` |
| Stop everything | `docker compose down` |
| Start everything | `./setup.sh` |
| Restart one app | `docker compose restart jellyfin` (use the app's name) |
| See an app's messages | `docker logs radarr` (use the app's name) |
| Update Jellyfin | change `JELLYFIN_VERSION` in `.env`, then `./setup.sh` |

🟦 **Path B:** do all of these in **Container Manager → Project → sovereign-media-stack → Action**.

---

## 🆘 Help! Something went wrong

| What you see | What to do |
|---|---|
| `permission denied` when typing `./setup.sh` | Type `chmod +x setup.sh` and try again |
| `docker: command not found` | Do Part 2 again |
| `permission denied while trying to connect to the Docker daemon` | You skipped logging out and back in (Step 2.4). Do it now. |
| `Please fill these in .env: ...` | Open `.env` again (Part 6) and fill in the line it names |
| The web page says **"can't be reached"** | 1) Did you type `http://` and not `https://`? 2) Is the address right? 3) Is the phone on the **same Wi-Fi**? 4) Wait 2 minutes, apps take time to start. |
| Part 8 shows **your real town** | Your VPN key is wrong or missing. Check `WIREGUARD_PRIVATE_KEY` in `.env`, then `./setup.sh`. Then type `docker logs gluetun` and look for words like `error` or `auth`. |
| qBittorrent page won't open | Same as above: the tunnel isn't working, so the truck is parked. Fix the VPN first. |
| An app says it **can't write** or has a **permission error** | Path A: `sudo chown -R 1000:1000 /your/config/folder /your/data/folder` (use **your** PUID:PGID numbers) |
| Jellyfin shows no posters | Use folder names like `Movie Name (2010)`, then **Scan All Libraries** |
| Radarr's **Test** is red | The host must be `gluetun` (not an IP), port `8080`, with your qBittorrent password |
| Totally stuck | Type `docker compose ps` and look for any app that isn't **running**, then `docker logs <that-app>` and read the last lines. Searching that error online usually finds the fix. |

---

## 🌟 You're done!

You now run your **own** streaming service. No monthly fee for it, nobody watching what you watch, and it's **yours**. High five! ✋
