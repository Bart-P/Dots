# n8n Docker

Pinned Docker Compose setup for the existing n8n data directory.

Data is not stored in this repo. The live n8n data remains at:

```text
/var/lib/n8n/.n8n
```

That directory contains the SQLite database, workflow data, binary data, and the n8n `config` file with the credential encryption key.

Start n8n:

```sh
docker compose up -d
```

Open:

```text
http://127.0.0.1:5678
```

Stop n8n:

```sh
docker compose down
```

Update n8n:

```sh
/home/bp/Dots/scripts/Scripts/n8n/n8n_update.sh 2.26.7
```

The update script requires an explicit target version. It creates a pre-upgrade data backup, saves a copy of `compose.yml`, updates the pinned Docker image, starts n8n, and waits for `http://127.0.0.1:5678`. If the new version fails to start, it restores the old `compose.yml`; if the new container may have touched the data, it also moves the upgraded data aside and restores the pre-upgrade backup before starting the old version again.

The container image is pinned in `compose.yml` and runs as UID/GID `956:956` to preserve the existing `/var/lib/n8n/.n8n` ownership. `HOME` and `N8N_USER_FOLDER` are set to `/home/node`, so n8n reads its data from `/home/node/.n8n`, which is bind-mounted to `/var/lib/n8n/.n8n`. The existing `/var/lib/n8n/.n8n/.cache` directory is also bind-mounted to `/home/node/.cache` because UID `956` cannot write to the image-owned cache path.
