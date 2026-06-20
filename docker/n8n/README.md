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

The container is pinned to n8n `1.115.3` and runs as UID/GID `956:956` to preserve the existing `/var/lib/n8n/.n8n` ownership. `HOME` and `N8N_USER_FOLDER` are set to `/home/node`, so n8n reads its data from `/home/node/.n8n`, which is bind-mounted to `/var/lib/n8n/.n8n`. The existing `/var/lib/n8n/.n8n/.cache` directory is also bind-mounted to `/home/node/.cache` because UID `956` cannot write to the image-owned cache path.
