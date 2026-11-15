# shaarli-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [Shaarli](https://github.com/shaarli/Shaarli).

## What this is

A four-file TOS Docker application archive (`shaarlidocker.tar.gz`) that installs
Shaarli on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `shaarlidocker`)
- `shaarlidocker.lang` — 23-language superset (TOS requires 14)
- `shaarlidocker.svg` — application icon (274 bytes, 2 SVG elements)
- `docker-compose.yml` — one service, image `shaarli/shaarli:v0.16.10`

## How it works

| | |
|---|---|
| Container image | `shaarli/shaarli:v0.16.10` (Docker Hub, used unmodified) |
| Open | `http://<NAS-IP>:8176/` (container port 8080) |
| Runs as | non-root, `user: "1000:1000"` |
| Persistent data | `/var/www/data` → `/Volume1/DockerAppData/shaarlidocker/data` |
| Logs | `docker logs shaarlidocker` (stdout/stderr) |

`/var/www/data` (mounted from `DockerAppData/shaarlidocker/data`) holds `config.json`, the datastore and the thumbnails cache.

## Design highlights

- **Non-root.** `user: "1000:1000"`; verified on real hardware (the container reports uid 1000).
- **Entrypoint wrapper**: serves the app with `php84 -S 0.0.0.0:8080` (Apache binds 80, unusable as uid 1000) and keeps the data folder on the volume.
- **Fixed image tag, never `:latest`**, Docker Hub only, no `privileged`, no `network_mode: host`, and no Docker socket, no `cap_add`.
- **Health check** probing the service on container port 8080.
- **Deterministic build**: GNU tar with uid/gid 0 and zeroed timestamps, gzip without a timestamp, plus the review-standards self-check above.
- **PHP built-in server.** Apache binds port 80, unusable as uid 1000; the wrapper uses the `php84` binary with `-S` on 8080.
- **No database.** Bookmarks live in a datastore file in the data folder.

## Privacy

This application runs entirely on your NAS. It does not include analytics, telemetry or advertising SDKs, and the packaging contains no code that sends data to the packager. Data is only exchanged with the services you configure yourself (for example media servers, notification endpoints or model APIs), and only from the container. Everything the application stores lives in the application data folder described above; removing the app with its data deletes it.

## Third-party components

The package runs the upstream image `shaarli/shaarli:v0.16.10` unmodified. Its components and their licences are those of the upstream project (https://github.com/shaarli/Shaarli), which is distributed under **Zlib**. No upstream source code is redistributed in this repository; only the four packaging files are original work.

## Runtime file manifest

Everything the application writes on the NAS lives inside its own data
directory; the container-internal `/tmp` is discarded with the container. The
table lists what is created and how it behaves. Nothing else is written.

| Path | Purpose | Created when | Growth bound | Lifecycle |
|---|---|---|---|---|
| `/Volume1/DockerAppData/shaarlidocker/data` | Shaarli application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |

## Build

```bash
scripts/build.sh                  # -> out/shaarlidocker.tar.gz + .sha256
scripts/build.sh 0.16.10-2   # packaging iteration bump
scripts/build.sh 0.16.10-1 aarch64
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes CRLF/BOM/AppleDouble, then runs
`tools/verify.py`, a review-standards self-check (archive layout, JSON validity,
required fields, 14+ language coverage, version consistency, Docker-Hub-only
images, fixed tag, reserved/recommended host ports, non-root user, per-service
healthcheck/TZ/restart, data path below the application data root, never the
`/Volume*` wildcard, comment-free sequence blocks, `x-app-meta` position, no
literal secrets and the SVG size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/shaarlidocker.tar.gz   # official spec check
bash test/install-and-verify.sh                  # on-device E2E (needs root)
```

> Docker applications cannot be side-loaded through the App Center's manual
> install page (it accepts `.deb` only); the official self-testing tool's `-i`
> mode or `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release **tag `v0.16.10-1`**, assets `shaarlidocker.tar.gz` +
   `shaarlidocker.tar.gz.sha256` (Docker asset naming: `<app_id>.tar.gz`, **no
   platform suffix**).
3. Developer platform → Add Application: ID `shaarlidocker`, package type Docker,
   repository URL, architecture `x86_64`.
4. Version Management → Add Version `0.16.10-1` → automated validation → review.

## License / branding

Shaarli is distributed by its upstream authors under **Zlib**. The container image is the official image from Docker Hub (`shaarli/shaarli:v0.16.10`) and is used unmodified; no upstream source code is redistributed here. This packaging is an independent community submission by Moechz and is not affiliated with the upstream project or TerraMaster.

## Limitations

- The built-in PHP server is single-threaded; fine for personal use.
- Thumbnail fetching may need outbound network access.
- The UI is plain HTTP; use a TLS reverse proxy before exposing it to the internet.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
