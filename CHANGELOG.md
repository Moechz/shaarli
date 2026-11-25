# Changelog

All notable user-visible changes to the Shaarli TOS application package.

## 0.16.11-1 — 2026-11-25

Remediation of the listing review of 0.16.10-2 (C10, C3, C4, C8, C9, T1).
The blocking item was the App Center install/self-test failure: the data folder
was mounted at a path the application never uses, the cache/template folders
were not writable at all and the web server ran without a URL router, so the
first-run page and the data folder were not usable.

### Fixed
- **Data was not persisted (F8).** The data folder was mounted at
  `/var/www/data`, but Shaarli reads and writes `/var/www/shaarli/data`. The
  package now mounts `data`, `cache`, `pagecache` and `tmp` at the paths the
  application actually uses, all below `/Volume1/DockerAppData/shaarlidocker/`.
  Bookmarks, settings and thumbnails survive restarts and updates.
- **Web UI could not complete installation (F5/F7).** Shaarli is a Slim
  application: `/install`, `/login`, `/admin` and `/shaare/...` need to be
  routed to `index.php`. PHP's built-in server was started without a router and
  returned 404 for those paths. The entrypoint now writes and uses a router
  that also blocks `data/`, `cache/`, `pagecache/`, `tmp/`, `vendor/`, `inc/`,
  `application/`, `tests/` and `.git/`.
- **Session cookie domain.** PHP's built-in server reported `0.0.0.0` as
  `SERVER_NAME`, so the session cookie was scoped to an invalid domain. The
  router now derives `SERVER_NAME`/`SERVER_PORT` from the request's `Host`
  header.
- **Writable directories.** The image ships `data`, `cache`, `pagecache` and
  `tmp` owned by its nginx user (uid 100). Running as uid 1000, the app could
  not write to them. All four are now mounted from the NAS and checked at
  startup, with a clear error if a mount is not writable.

### Security
- Upgraded the upstream image to **0.16.11**, which fixes the LDAP
  empty-password issue (GHSA-xqxc-g4w2-w7vv) and CVE-2026-118773 in a bundled
  npm dependency, and refreshes the Alpine base to 3.24.3 (T1).
- The image remains pinned to `shaarli/shaarli:v0.16.11` on Docker Hub (never
  `:latest`), with no `privileged`, no `cap_add`, no host network and no Docker
  socket. The container still runs as uid 1000.
- The web server refuses to serve the data, cache, template and vendor paths.

### Compliance
- Added `PRIVACY.md` (C3/C4): what is stored and where, retention period, user
  rights, security measures, third-party sharing, deletion channel and contact.
- Added `NOTICE.md`: upstream Zlib licence, image source and digest, trademark
  ownership and the MIT licence of this packaging (C10).
- Added a third-party API disclosure table to `PRIVACY.md` and `README.md`
  (C8): the page you bookmark, the GitHub update check, Docker Hub and the
  optional plugins, with the data sent and the destination.
- Rewrote the English, Simplified Chinese and Traditional Chinese descriptions
  (C9) so they describe the delivered features only. The simplified/traditional
  entries were still template text from another application. The `.lang` file
  no longer contains ASCII semicolons.
- Pointed the package `help` field and `config.ini.help` at the public privacy
  policy, and completed the README with repository layout, privacy, notices,
  build, verification and data/uninstall sections (C10).
- Documented the uninstall residue: Docker packages have no uninstall hook;
  `data/` is kept and can be removed manually (F11).

### Changed
- Version `0.16.11-1` (upstream 0.16.11, packaging iteration 1).
- The entrypoint `exec`s the web server as PID 1, so stop signals reach it and
  no supervisor processes are left behind (F3).
- The health check now performs an HTTP request with `wget` instead of scanning
  `/proc/net/tcp`.

## 0.16.10-1 — 2026-11-15

### Added
- First release. Shaarli (`shaarli/shaarli:v0.16.10`, Docker Hub image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8176 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/shaarlidocker/`.
