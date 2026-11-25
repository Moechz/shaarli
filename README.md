# Shaarli for TerraMaster TOS 7

> TerraMaster TOS 7 App Center — **Docker application** package for
> [Shaarli](https://github.com/shaarli/Shaarli), a self-hosted bookmark manager.

This repository contains the packaging only. It does **not** redistribute the
Shaarli source code: the package runs the upstream project image
`shaarli/shaarli:v0.16.11` from Docker Hub unmodified.

## What this is

A four-file TOS Docker application archive (`shaarlidocker.tar.gz`) that installs
Shaarli on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `shaarlidocker`)
- `shaarlidocker.lang` — 23-language text superset (TOS requires 14)
- `shaarlidocker.svg` — application icon
- `docker-compose.yml` — one service, image `shaarli/shaarli:v0.16.11`

Two architecture-specific archives are published for every release:

- `shaarlidocker_x86_64.tar.gz` — `platform: x86_64`
- `shaarlidocker_aarch64.tar.gz` — `platform: aarch64`

The upstream image is a multi-arch OCI index (`linux/amd64`, `linux/arm64`,
`linux/arm/v7`), so the same compose file works on both TOS architectures.

## How it works

| | |
|---|---|
| Container image | `shaarli/shaarli:v0.16.11` (Docker Hub, used unmodified) |
| Open | `http://<NAS-IP>:8176/` (container port 8080) |
| Runs as | non-root, `user: "1000:1000"` |
| Application data | `/var/www/shaarli/data` → `/Volume1/DockerAppData/shaarlidocker/data` |
| Thumbnails | `/var/www/shaarli/cache` → `/Volume1/DockerAppData/shaarlidocker/cache` |
| Page cache | `/var/www/shaarli/pagecache` → `/Volume1/DockerAppData/shaarlidocker/pagecache` |
| Compiled templates | `/var/www/shaarli/tmp` → `/Volume1/DockerAppData/shaarlidocker/tmp` |
| Logs | `docker logs shaarlidocker` (stdout/stderr) and `data/log.txt` |
| Health check | `wget -q -O /dev/null http://127.0.0.1:8080/` every 30 s |

The upstream image serves nginx + php-fpm on port 80 as its own `nginx` user
(uid 100). TOS requires a non-root application user, so the entrypoint runs
PHP's built-in web server as uid 1000 on port 8080 with a small router:

- `/install`, `/login`, `/admin`, `/shaare/...` and the REST API routes are
  handed to `index.php` (Shaarli is a Slim application and needs URL rewriting);
- static assets (CSS, JS, images, fonts) are served directly;
- `data/`, `cache/`, `pagecache/`, `tmp/`, `vendor/`, `inc/`, `application/`,
  `tests/` and `.git/` are refused, so `config.json.php`, the datastore and
  sessions are never exposed over HTTP;
- `SERVER_NAME` is taken from the request's `Host` header, because the built-in
  server otherwise reports `0.0.0.0` and Shaarli would set an unusable session
  cookie domain.

The data, cache, page-cache and template directories are mounted from
`DockerAppData`; without those mounts uid 1000 cannot write to the directories
that the image ships owned by its nginx user. This was the root cause of the
data-loss and first-run failures fixed in `0.16.11-1`.

## Repository layout

```text
.
├── src/
│   ├── config.ini              # TOS metadata (id, version, port, help link)
│   ├── docker-compose.yml      # service, ports, 4 mounts, healthcheck
│   ├── entrypoint.sh           # non-root wrapper + URL router (staged into compose)
│   ├── shaarlidocker.lang      # 23-language description file (generated)
│   └── shaarlidocker.svg       # 512×512 store icon
├── scripts/
│   ├── build.sh                # one architecture → out/shaarlidocker.tar.gz
│   └── build-dual.sh           # both architectures + official -c check
├── tools/
│   └── verify.py               # review-standards self-check used by build.sh
├── test/
│   └── install-and-verify.sh   # on-device install/verify helper (root required)
├── TOSAppSelfTestingTool       # TerraMaster official spec checker (unmodified)
├── PRIVACY.md                  # privacy policy (C3/C4/C8)
├── NOTICE.md                   # licences, image digest, trademarks
├── CHANGELOG.md
├── README.md
└── LICENSE                     # MIT for this packaging; upstream Zlib in NOTICE
```

## Privacy

The app runs **entirely on your NAS**. The developer receives no bookmarks,
account data or telemetry, and operates no server. Data is only sent to the
sites and services described in [PRIVACY.md](PRIVACY.md), which is also linked
from the app's Help field:

- the page you bookmark (when you fetch its title/description or enable
  thumbnails) — an ordinary HTTP request from the NAS to that site;
- `raw.githubusercontent.com` — one update check per day, only while an
  administrator is logged in, carrying no bookmark data;
- Docker Hub — the image pull;
- optional plugins you choose to enable (PubSubHubbub, Piwik/Matomo, Isso,
  Wallabag, PlayVideos) — their configured endpoints, disabled by default.

The full retention period, user-rights and deletion channel are in
[PRIVACY.md](PRIVACY.md).

## Third-party API disclosure

| Endpoint | When | Data sent | Destination |
|---|---|---|---|
| The URL you save, plus its images when a thumbnail is fetched | on metadata/thumbnail retrieval (thumbnails are opt-in) | the URL and a normal HTTP GET; no account or NAS data | the site you chose |
| `raw.githubusercontent.com/shaarli/Shaarli/release/shaarli_version.php` | at most once per 24 h, admin logged in | IP address and user agent | GitHub, US |
| `registry-1.docker.io`, `auth.docker.io` | install/upgrade | anonymous pull, IP address and user agent | Docker Hub, US / your mirror |
| `pubsubhubbub.appspot.com` (optional plugin) | when a bookmark is saved and the plugin is enabled | public feed URLs | Google, US |
| Your Piwik/Matomo, Isso or Wallabag URL (optional plugins) | only if you enable and configure the plugin | the data that plugin is designed to send | your own server |
| YouTube embeds (optional PlayVideos plugin) | when you open the video player | browser IP address and user agent | Google / YouTube, US |

The developer does not receive any of this data. There is no analytics SDK, no
advertising and no crash reporting.

## Notices and licensing

- Upstream **Shaarli** is distributed under the **Zlib** licence. This package
  runs the upstream image unmodified and redistributes no upstream source.
- The container image is `shaarli/shaarli:v0.16.11` (Docker Hub), multi-arch OCI
  index digest
  `sha256:cbc8595e29a065754e2010c36e7126b1a2f634ec83be3c786602c0783d758e1f`.
- The packaging files in this repository are **MIT** licensed (see `LICENSE`).
- Shaarli and the Shaarli logo belong to the upstream project. TerraMaster, TOS
  and App Center are trademarks of TerraMaster. This is an independent community
  package, not affiliated with either party.

See [NOTICE.md](NOTICE.md) for the complete notice.

## Build

Requirements: `python3` and GNU `tar`/`gzip`. The build is pure Python + tar/gzip;
it needs no Docker daemon and no network access.

```bash
scripts/build.sh                       # current version, current platform
scripts/build.sh 0.16.11-1 aarch64     # explicit version + architecture
scripts/build-dual.sh 0.16.11-1        # both architectures, then official -c
```

`scripts/build-dual.sh` produces:

```text
out/shaarlidocker_x86_64.tar.gz   + .sha256
out/shaarlidocker_aarch64.tar.gz  + .sha256
```

`build.sh` stages the four package files, substitutes the version/platform
tokens, embeds `src/entrypoint.sh` into the compose block scalar (escaping every
`$` as `$$`), strips CRLF/BOM/AppleDouble files and runs `tools/verify.py`.
The verifier is a hard gate covering archive layout, JSON validity, required
fields, 14+ language coverage, version consistency, Docker-Hub-only images,
fixed tags, recommended host ports, non-root user, per-service healthcheck/TZ/
restart, data paths below the application data root, comment-free sequence
blocks, `x-app-meta` position, no literal secrets, and the SVG size/element
limits.

## Local verification

```bash
./TOSAppSelfTestingTool -c out/shaarlidocker_x86_64.tar.gz
./TOSAppSelfTestingTool -c out/shaarlidocker_aarch64.tar.gz
```

Both checks must print `check passed`. The on-device helper
`test/install-and-verify.sh` is optional and must be run as the TOS
administrator. Docker applications cannot be side-loaded through the App
Center's manual install page (it accepts `.deb` only).

## Data, backup and uninstall

All persistent state is below `/Volume1/DockerAppData/shaarlidocker/`:

| Folder | Contents | Regenerable |
|---|---|---|
| `data/` | `config.json.php` (account hash, settings), `datastore.php` (bookmarks, tags), `history.php`, `ipbans.php`, `log.txt`, `lastupdatecheck.txt` | **No** — back this up |
| `cache/` | downloaded thumbnails | yes |
| `pagecache/` | rendered pages | yes |
| `tmp/` | compiled RainTPL templates | yes |

Back up `data/` before upgrading. Removing the app from the App Center keeps the
data folder (Docker packages have no uninstall hook); to delete everything, stop
the container and remove `/Volume1/DockerAppData/shaarlidocker/`. The app can
also export all bookmarks as a Netscape HTML file via “Tools → Export”.

## Review remediation — 0.16.11-1

This release addresses the listing review of `0.16.10-2`:

| Code | Finding | Change |
|---|---|---|
| C10 | Repository/directory compliance | Public repository, complete README with layout, privacy, notices, build and data/uninstall sections. |
| C3 | Privacy policy missing | Added `PRIVACY.md`, linked from the package `help` field and this README. |
| C4 | Privacy policy incomplete | Covers retention, user rights, security measures, third-party sharing and the deletion channel. |
| C8 | Third-party API usage not disclosed | Endpoint/data/destination table for the bookmark fetch, update check, Docker Hub and optional plugins. |
| C9 | Description inconsistent with delivered functionality | Rewrote `descript`, `important` and `release_note`; rewrote `zh-cn`/`zh-hk` (they were template text); no ASCII semicolons in the `.lang` file. |
| T1 | High/critical CVE | Upgraded to upstream `0.16.11` (LDAP empty-password fix GHSA-xqxc-g4w2-w7vv, CVE-2026-118773 in a bundled npm dependency, Alpine 3.24.3 base). |
| F5/F7/F8 | Declared functionality not usable, web UI broken, data not persisted | Fixed the writable-path mounts (data/cache/pagecache/tmp) and added the URL router; verified install → login → save bookmark → restart on staging. |
| F11 | Residual data after uninstall | Documented every data/cache path and the manual deletion step. |
| F3 | Service fails to stop cleanly | The wrapper `exec`s the web server as PID 1, so stop signals reach it and no supervisor leaves zombies behind. |
| S11/V1 | File permissions not minimised | Runs as uid 1000 with no `privileged`, `cap_add`, host network or Docker socket. |

## Limitations

- The built-in PHP web server is not a full web server. It is adequate for a
  personal bookmark manager and is fronted by the TOS App Center, but it does
  not replace nginx for heavy multi-user traffic.
- Thumbnail and metadata retrieval needs outbound network access to the sites
  you bookmark.
- The UI is plain HTTP; use a TLS reverse proxy before exposing it to the
  internet.
- Shaarli is single-user by design (one administrator account), not a
  multi-tenant service.

## Store submission checklist

1. Public GitHub repository with this README, `PRIVACY.md` and `NOTICE.md`.
2. Release tag `v0.16.11-1` with assets `shaarlidocker_x86_64.tar.gz`,
   `shaarlidocker_aarch64.tar.gz` and their `.sha256` files.
3. Developer platform → application `shaarlidocker`, package type Docker,
   repository URL, architecture `x86_64` and `aarch64`.
4. Version management → add version `0.16.11-1` → automated validation → review.

## Contact

Packaged for TOS 7 by **Moechz** — moechz@163.com —
<https://www.moechz.com/privacy.html>. Upstream image used unmodified from
Docker Hub.
