#!/bin/sh
# ===========================================================================
# Shaarli entrypoint for a non-root container (TOS 7 requirement).
#
# The upstream image runs nginx + php-fpm on port 80 as its own nginx user
# (uid 100), and its data/cache/tmp directories belong to that user. This
# package runs as uid 1000, cannot bind port 80 and cannot write those
# directories. The wrapper:
#   1. checks that the four mounted writable directories are usable;
#   2. starts PHP's built-in web server on port 8080 with a router script,
#      because Shaarli is a Slim application and needs /install, /login,
#      /admin and /shaare/... routed to index.php;
#   3. keeps the application data on the mounted volume.
# ===========================================================================
set -e
set -u

DATA=/var/www/shaarli/data
CACHE=/var/www/shaarli/cache
PAGECACHE=/var/www/shaarli/pagecache
TMP=/var/www/shaarli/tmp

for dir in "$DATA" "$CACHE" "$PAGECACHE" "$TMP"; do
  mkdir -p "$dir" 2>/dev/null || true
done

for dir in "$DATA" "$CACHE" "$PAGECACHE" "$TMP"; do
  if ! ( : > "$dir/.write-test" ) 2>/dev/null; then
    echo "shaarli: $dir is not writable by uid $(id -u)" >&2
    exit 1
  fi
  rm -f "$dir/.write-test"
done

cat > /tmp/shaarli-router.php <<'PHP'
<?php
/**
 * Router for PHP's built-in web server.
 *
 * Shaarli is a Slim application: every route (/, /install, /login, /admin,
 * /shaare/...) has to be handed to index.php. Static assets are served by the
 * built-in server itself. Data, cache, template and vendor directories are
 * never served, mirroring the .htaccess / nginx rules of the upstream image.
 */
$root = '/var/www/shaarli';
$uri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($uri, PHP_URL_PATH) ?: '/';

foreach (array('/data/', '/cache/', '/pagecache/', '/tmp/', '/vendor/', '/inc/',
               '/application/', '/tests/', '/.git/') as $prefix) {
    if (strpos($path, $prefix) === 0) {
        http_response_code(404);
        return true;
    }
}

if (strpos($path, '..') === false
    && preg_match('#\.(?:ico|css|js|gif|jpe?g|png|ttf|otf|woff2?)$#i', $path)
    && is_file($root . $path)) {
    return false; // let the built-in server stream the file
}

// PHP's built-in server reports the bind address (0.0.0.0) as SERVER_NAME.
// Shaarli derives absolute URLs and the session cookie domain from it, so use
// the host the client actually requested instead.
$host = $_SERVER['HTTP_HOST'] ?? '';
if (preg_match('/^(\[[^\]]+\]|[^:]+)(?::(\d+))?$/', $host, $matches)) {
    $_SERVER['SERVER_NAME'] = $matches[1];
    if (!empty($matches[2])) {
        $_SERVER['SERVER_PORT'] = $matches[2];
    }
}

$_SERVER['SCRIPT_NAME'] = '/index.php';
$_SERVER['SCRIPT_FILENAME'] = $root . '/index.php';
$_SERVER['PHP_SELF'] = '/index.php';

require $root . '/index.php';
PHP

PHP_BIN=php84
command -v "$PHP_BIN" >/dev/null 2>&1 || PHP_BIN=php

cd /var/www/shaarli
# A thumbnail/metadata fetch can take a few seconds; a few workers keep the UI
# responsive while one request waits for a remote page.
export PHP_CLI_SERVER_WORKERS="${PHP_CLI_SERVER_WORKERS:-4}"

exec "$PHP_BIN" -S 0.0.0.0:8080 -t /var/www/shaarli /tmp/shaarli-router.php
