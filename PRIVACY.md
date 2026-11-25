# Privacy Policy — Shaarli for TerraMaster TOS (`shaarlidocker`)

**Last updated:** 25 November 2026
**Data controller / contact:** Moechz — moechz@163.com
**Applies to:** version `0.16.11-1` and later of the TOS application
`shaarlidocker`, the container image it runs and this repository.

## 1. Summary

- The application runs **entirely on your NAS**. The developer does not receive,
  collect or have access to your bookmarks, tags, account or settings.
- There is **no telemetry, no analytics, no advertising and no account** operated
  by the developer, and no cloud service is used.
- The container contacts only: the pages you choose to bookmark, GitHub (one
  update check per day when an administrator is logged in) and Docker Hub (image
  pull). Optional plugins you enable can contact the services you configure.
- The app is **single-user** by design: one administrator account, plus optional
  public visitors for links you mark public.

## 2. What data is processed

| Data | Stored on the NAS at |
|---|---|
| Bookmarks: URL, title, description, tags, private/public flag, timestamps | `/Volume1/DockerAppData/shaarlidocker/data` (datastore file) |
| Administrator account: username, password hash and salt, session data | `/Volume1/DockerAppData/shaarlidocker/data` (`config.json.php`) and the container's PHP session storage |
| Settings: title, timezone, language, theme, plugin configuration | `/Volume1/DockerAppData/shaarlidocker/data` (`config.json.php`) |
| Update-check result (latest known Shaarli version string) | `/Volume1/DockerAppData/shaarlidocker/data/lastupdatecheck.txt` |
| Downloaded thumbnails of bookmarked pages | `/Volume1/DockerAppData/shaarlidocker/cache` |
| Rendered-page cache and compiled templates | `/Volume1/DockerAppData/shaarlidocker/pagecache` and `/Volume1/DockerAppData/shaarlidocker/tmp` |
| Container logs (stdout/stderr) | Docker's log buffer only; `docker logs shaarlidocker` |

The administrator password is stored only as a salted hash created by Shaarli.
It is never sent to the developer or to any third party. Public visitors do not
have an account. The app does not ask for an email address, phone number or any
other personal identifier.

## 3. Retention period

- **Bookmarks, tags, settings and the administrator account:** kept until **you**
  delete them. There is no automatic expiry and no upload. Uninstalling the app
  keeps the data folder unless you tick “delete data” or remove it yourself.
- **Thumbnails, page cache and compiled templates:** rebuilt on demand. They can
  be deleted at any time from the app (Configure → clear cache) or by removing
  the three cache folders. They never contain data that is not already in the
  data folder.
- **Logs:** stdout/stderr only; the Docker daemon keeps them according to its own
  rotation settings. Shaarli may also write `data/log.txt`, which you can delete.
- **Update-check file:** contains only the latest version string, overwritten at
  most once per day.

## 4. Your rights and the deletion channel

| Right | How |
|---|---|
| Access / export | “Tools → Export” in the Shaarli UI writes a Netscape HTML file with all bookmarks and tags. Copy `/Volume1/DockerAppData/shaarlidocker/` for the complete state (including settings and thumbnails). |
| Correct | Edit the bookmark, tag or account in the app's own web UI. |
| Delete | Delete a bookmark in the UI, uninstall the app with “delete data”, or stop the container and remove `/Volume1/DockerAppData/shaarlidocker/`. |
| Restrict processing | Do not enable optional plugins that contact external services, and block outbound traffic from the container if you want it fully offline. |
| Assistance | Email **moechz@163.com** with the subject “Shaarli data request”; a reply follows within 30 days. |

The developer holds no copy of your data, so deletion is normally completed by
removing the folder on your own NAS. The email channel exists for questions and
for requests about the website or the publishing records.

## 5. Security measures

- The container runs as **uid 1000**, never root; no `privileged`, no `cap_add`,
  no host network and no Docker socket.
- Only the application's own port is published (host 8176 → container 8080).
- The image tag is **pinned** (`shaarli/shaarli:v0.16.11`), never `:latest`; the
  package is rebuilt when upstream ships security fixes.
- Data stays inside the application data folder, owned by the app user. The web
  server refuses to serve `data/`, `cache/`, `pagecache/`, `tmp/`, `vendor/`,
  `inc/`, `application/` and `.git/` paths.
- Change the administrator password after installation. If you expose the UI
  outside the LAN, put it behind a TLS reverse proxy and keep the app updated.

## 6. Third-party sharing and API disclosure

The developer shares nothing. The app contacts only the endpoints below, and
only from the container on your NAS.

| Service | Endpoint | Data sent | Destination / region |
|---|---|---|---|
| Page you bookmark (metadata and thumbnails) | the exact URL you save, plus the page's own images when a thumbnail is fetched; this happens when you ask for metadata or enable thumbnails | an ordinary HTTP GET for that URL — no account, password or NAS data | the site you chose (anywhere on the internet) |
| Shaarli update check | `raw.githubusercontent.com/shaarli/Shaarli/release/shaarli_version.php` | an HTTP GET with your NAS's IP address and user agent; no bookmark or account data | GitHub, United States |
| Container image pull | `registry-1.docker.io`, `auth.docker.io` (or the registry mirror configured on your NAS) | anonymous image pull; IP address and user agent | Docker Hub, United States / your mirror |
| PubSubHubbub plugin (optional, disabled by default) | `https://pubsubhubbub.appspot.com/` by default, configurable | your public feed URLs, published when a bookmark is saved | Google, United States |
| Piwik / Matomo plugin (optional, disabled by default) | the URL you configure | page views and the visitor's IP address, as configured by you | your own analytics server |
| Isso comments plugin (optional, disabled by default) | the URL you configure | comment text and metadata, as configured by you | your own comment server |
| Wallabag plugin (optional, disabled by default) | the URL you configure | the bookmark URL and title you choose to send | your own Wallabag server |
| PlayVideos plugin (optional, disabled by default) | YouTube embeds loaded by your browser | your browser's IP address and user agent | Google / YouTube, United States |

Notes:

- The **bookmark fetch** is the only request that carries the URL you saved. It is
  made by the Shaarli server, not by your browser, and reveals the NAS's IP
  address to that site. Thumbnails are opt-in: “Configure → Thumbnails” is
  disabled by default.
- The **update check** runs only when an administrator is logged in, at most once
  per 24 hours. It can be disabled in “Configure → Update check”.
- The **image pull** happens once per install/upgrade.
- Bundled plugins are disabled by default except the local QR-code plugin. The
  archive.org plugin only adds a link to `web.archive.org`; it makes no request.
- The developer operates no server and receives no data from any of these
  requests.

## 7. Children

The app is a self-hosted utility for personal bookmarking and is not directed at
children.

## 8. Changes

Material changes are published in this file and reflected in the “Last updated”
date. The policy also ships with every release of the package and is linked from
the app's Help field.

## 9. Contact

Moechz — **moechz@163.com** — <https://www.moechz.com/privacy.html>

## 10. Scope

This policy covers the TOS package `shaarlidocker` (the four packaging files,
the entrypoint wrapper and the documentation in this repository) and the
unmodified upstream image `shaarli/shaarli:v0.16.11`. The upstream Shaarli
project has its own documentation at <https://shaarli.readthedocs.io>.
