# Notices — Shaarli for TerraMaster TOS (`shaarlidocker`)

This repository is an independent community package for TerraMaster TOS 7. It
is not affiliated with the upstream Shaarli project or with TerraMaster.

## Upstream application

- **Shaarli** — <https://github.com/shaarli/Shaarli>
- Copyright © 2011–2015 Sébastien Sauvage and © 2011–2026 the Shaarli Community,
  see the upstream `AUTHORS` file.
- Distributed under the **zlib/libpng licence** (Zlib). The upstream copyright
  and licence inventory is in `COPYING` in the upstream source tree:
  <https://github.com/shaarli/Shaarli/blob/master/COPYING>. The zlib terms are:

  > This software is provided 'as-is', without any express or implied warranty.
  > In no event will the authors be held liable for any damages arising from the
  > use of this software.
  >
  > Permission is granted to anyone to use this software for any purpose,
  > including commercial applications, and to alter it and redistribute it
  > freely, subject to the following restrictions:
  >
  > 1. The origin of this software must not be misrepresented; you must not
  >    claim that you wrote the original software. If you use this software in a
  >    product, an acknowledgment in the product documentation would be
  >    appreciated but is not required.
  > 2. Altered source versions must be plainly marked as such, and must not be
  >    misrepresented as being the original software.
  > 3. This notice may not be removed or altered from any source distribution.
- This package runs the upstream application **unmodified**; no upstream source
  code is redistributed here. Only the packaging files (`config.ini`,
  `shaarlidocker.lang`, `shaarlidocker.svg`, `docker-compose.yml`, the
  entrypoint wrapper, the build scripts and the documentation) are original
  work of the packager.

## Container image

- Image: `shaarli/shaarli:v0.16.11` from Docker Hub, used unmodified.
- Multi-arch OCI index digest:
  `shaarli/shaarli@sha256:cbc8595e29a065754e2010c36e7126b1a2f634ec83be3c786602c0783d758e1f`.
- Platforms in the index: `linux/amd64`, `linux/arm64`, `linux/arm/v7`.
- The image bundles nginx, PHP 8.4, s6 and the Composer/npm dependencies of the
  upstream release. Their licences are those of the upstream project and of the
  respective components; they are not re-licensed by this package.
- The app's Docker Hub page and the upstream `Dockerfile` are the authoritative
  source for the image contents.

## Trademarks

- **Shaarli** and the Shaarli logo belong to the upstream project and its
  contributors. They are used here only to describe the software that this
  package installs.
- **TerraMaster**, **TOS** and **App Center** are trademarks of TerraMaster.
  They are used here only to describe the target platform.
- All other trademarks belong to their respective owners. No endorsement or
  affiliation is implied.

## This packaging

- Copyright © 2026 Moechz.
- The packaging files in this repository are released under the **MIT licence**;
  see `LICENSE`.
- `TOSAppSelfTestingTool` is an official TerraMaster utility, redistributed here
  unmodified for local package validation. It is not covered by the MIT licence
  of the packaging files.

## Privacy

The privacy policy for this application is in `PRIVACY.md` and is linked from
the package's `help` field:
<https://github.com/Moechz/shaarli/blob/main/PRIVACY.md>.

## Contact

Moechz — **moechz@163.com** — <https://www.moechz.com/privacy.html>
