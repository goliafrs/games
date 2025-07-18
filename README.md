# Game Servers Docker Compose

## Disclaimer

> **This is my personal setup for running game servers with Docker Compose.**

> I do not claim it is perfect, nor do I provide support or troubleshooting for others.
> Use at your own risk. Everything is provided as-is.

---

## Description

This project is designed for quick deployment and management of game servers using Docker Compose and bash scripts.  
The goal is to minimize routine when launching, updating, backing up, and restoring servers.

---

## Quick Start

1. Clone the repository:

    ```bash
    git clone https://github.com/goliafrs/games.git
    cd games
    ```

2. Install [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/).
3. Set up [rclone](https://rclone.org/) for backups (optional).

4. (Optional but recommended) Create a symbolic link to `games.sh` for global access:  
   Replace `/path/to/games` with the actual path where you cloned the repository.

   ```bash
   ln -s /path/to/games/games.sh /usr/local/bin/games
   ```

   Now you can run `games` from anywhere.

5. (Optional) Enable bash completion for commands:  
   Add the following line to your `~/.bashrc` (replace `/path/to/games` as above):

   ```bash
   source /path/to/games/_completions.sh
   ```

   Then reload your shell:

   ```bash
   source ~/.bashrc
   ```

6. Start a server:

    ```bash
    games <game> [command]
    # or, if you skip 4 and 5 step
    /path/to/games/games.sh <game> [command]
    ```

Example:

```bash
games ark start
# or if you skip 4 and 5 step
/path/to/games/games.sh ark start
```

---

## Supported Game Servers and Used Images

| Game                          | Docker Image                                                                                                                             | Links to Sources/Docs                                                                             |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **ARK: Survival Evolved**     | [steamcmd/steamcmd:latest](https://hub.docker.com/r/steamcmd/steamcmd)                                                                   | [ark-server-tools (GitHub)](https://github.com/arkmanager/ark-server-tools)                       |
| **Astroneer**                 | [mcrcon/astroneer-dedicated-server](https://hub.docker.com/r/mcrcon/astroneer-dedicated-server)                                          | [astroneer-dedicated-server (GitHub)](https://github.com/mcrcon/astroneer-dedicated-server)       |
| **Avorion**                   | [steamcmd/steamcmd:latest](https://hub.docker.com/r/steamcmd/steamcmd)                                                                   | [Avorion (Steam)](https://store.steampowered.com/app/445220/Avorion/)                             |
| **Eco**                       | [strangeloopgames/eco-server](https://hub.docker.com/r/strangeloopgames/eco-server)                                                      | [Eco Server (GitHub)](https://github.com/StrangeLoopGames/Eco)                                    |
| **Factorio**                  | [factoriotools/factorio](https://hub.docker.com/r/factoriotools/factorio)                                                                | [factoriotools/factorio (GitHub)](https://github.com/factoriotools/factorio-docker)               |
| **Foundry**                   | [foundry-rs/foundry](https://hub.docker.com/r/foundry-rs/foundry)                                                                        | [foundry-rs/foundry (GitHub)](https://github.com/foundry-rs/foundry)                              |
| **Icarus**                    | [ghcr.io/mbround18/icarus-dedicated-server](https://github.com/mbround18/icarus-dedicated-server/pkgs/container/icarus-dedicated-server) | [icarus-dedicated-server (GitHub)](https://github.com/mbround18/icarus-dedicated-server)          |
| **Minecraft (Steam Punk)**    | [itzg/minecraft-server](https://hub.docker.com/r/itzg/minecraft-server)                                                                  | [itzg/minecraft-server (GitHub)](https://github.com/itzg/docker-minecraft-server)                 |
| **Minecraft (Vault Hunters)** | [itzg/minecraft-server](https://hub.docker.com/r/itzg/minecraft-server)                                                                  | [itzg/minecraft-server (GitHub)](https://github.com/itzg/docker-minecraft-server)                 |
| **Palworld**                  | [thijsvanloef/palworld-server-docker](https://hub.docker.com/r/thijsvanloef/palworld-server-docker)                                      | [palworld-server-docker (GitHub)](https://github.com/ThijsvanLoef/palworld-server-docker)         |
| **Satisfactory**              | [wolveix/satisfactory-server](https://hub.docker.com/r/wolveix/satisfactory-server)                                                      | [wolveix/satisfactory-server (GitHub)](https://github.com/wolveix/satisfactory-server)            |
| **Sons Of The Forest**        | [ich777/sonsoftheforest-server](https://hub.docker.com/r/ich777/sonsoftheforest-server)                                                  | [ich777/sonsoftheforest-server (GitHub)](https://github.com/ich777/docker-sonsoftheforest-server) |
| **Space Engineers**           | [torchapi/space-engineers](https://hub.docker.com/r/torchapi/space-engineers)                                                            | [torchapi/space-engineers (GitHub)](https://github.com/torchapi/docker-space-engineers)           |
| **Valheim**                   | [lloesche/valheim-server](https://hub.docker.com/r/lloesche/valheim-server)                                                              | [lloesche/valheim-server (GitHub)](https://github.com/lloesche/valheim-server-docker)             |

> **Note:**  
> Some servers use official or community images, and some use custom Dockerfiles based on them.

---

## Main Commands

```bash
games <game> [command]
/path/to/games/games.sh <game> [command]
```

- **start** — Start the server
- **stop** — Stop the server
- **restart** — Restart the server
- **logs** — View logs
- **attach** — Attach to the container via bash
- **destroy** — Stop and remove the container
- **cleanup** — Remove unused docker resources
- **reset** — Full data wipe and restart
- **backup** — Backup data (with rclone)
- **init** — Set permissions and create a symlink for quick launch
- **cron** — Add backup and restart jobs to cron

---

## DayZ

> **This guide explains how to run your own DayZ server using Docker Compose.**

---

### How it works

- On every container start, the main server config file (by default `serverDZ.cfg`, or as set in `CONFIG_FILE`) is fully regenerated from environment variables. All config values are controlled via environment variables in `docker-compose.yml` or `.env`.
- If the config file does not exist, it will be created automatically.
- Any changes to environment variables require a container restart (`docker compose up -d`) to apply.
- Mods are downloaded and linked automatically if you specify both `MODS` and `MODS_IDS`.
- All persistent data (world, configs, Steam auth, mods) is stored in volumes. Deleting these folders will reset your server and Steam login.

**You can control all server settings via environment variables. Manual edits to the config file will be overwritten on next start.**

---

### 1. Prerequisites

- Install [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/).
- Clone this repository and go to the DayZ directory:

    ```bash
    git clone https://github.com/goliafrs/games.git
    cd games/dayz
    ```

---

### 2. Volumes: Persistent Data & Steam Auth

- **You must use volumes for `/root/Steam` and `/root/.local/share`** to persist Steam authentication and avoid entering Steam Guard code every time.
- Volume for `/root/dayz` (e.g. `./data:/root/dayz`) is required to persist server data (world, configs, etc).
- Do **not** delete the `./share`, `./steam`, or `./data` folders on your host — they store your server state and Steam credentials.

**Example docker-compose.yml volumes section:**

```yaml
volumes:
  - ./data:/root/dayz
  - ./share:/root/.local/share
  - ./steam:/root/Steam
```

---

### 3. Environment Variables

- **STEAM_USER** and **STEAM_PASS** — your Steam login and password (use a `.env` file or export variables for security).
- **MODS** — list of mod folder names (e.g. `@CF;@Community-Online-Tools`)
- **MODS_IDS** — list of corresponding Steam Workshop IDs (e.g. `1559212036;1564026768`)
- **Order of MODS and MODS_IDS must match!**
- All other server/game settings can be set as environment variables (see `docker-compose.yml` for examples and defaults).

**Example:**

```yaml
environment:
  - STEAM_USER=your_steam_login
  - STEAM_PASS=your_steam_password
  - HOSTNAME=My DayZ Server
  - MODS=@CF;@Community-Online-Tools
  - MODS_IDS=1559212036;1564026768
  # ...other settings...
```

---

### 4. First Launch & Steam Guard

1. Build and start the container:

    ```bash
    docker compose up --build
    ```

2. On first launch, SteamCMD will ask for a Steam Guard code.
   Open a second terminal and run:

    ```bash
    docker attach dayz
    ```

   Enter the Steam Guard code from your email or Steam app.
3. After successful login, Steam Guard will not be required again (unless you delete the volumes).

---

### 5. Main Commands

- **Start server:**  

    ```bash
    docker compose up -d
    ```

- **Stop server:**  

    ```bash
    docker compose down
    ```

- **Rebuild and restart:**  

    ```bash
    docker compose up --build
    ```

- **View logs:**  

    ```bash
    docker compose logs -f
    ```

- **Enter container shell:**  

    ```bash
    docker exec -it dayz bash
    ```

---

### 6. Tips & Notes

- **Do not use `--build` unless you changed the Dockerfile or dependencies.**
- **Never delete your volume folders** (`./data`, `./share`, `./steam`) unless you want to reset everything.
- **Mods:**  
  - Always specify both `MODS` and `MODS_IDS` (semicolon-separated, same order).
  - Mods are downloaded and linked automatically.
- **Config changes:**  
  - After changing environment variables, restart the container:  

    ```bash
    docker compose up -d
    ```

---

**If you have issues, check comments in `docker-compose.yml` for more details.**
