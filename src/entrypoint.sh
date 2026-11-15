#!/bin/sh
# ===========================================================================
# Shaarli entrypoint for a non-root container (TOS 7 requirement).
#
# The image runs Apache on port 80 (unusable as uid 1000) and its PHP CLI is
# named php84. This wrapper runs the built-in PHP web server on port 8080 and
# keeps the data folder on the mounted volume.
# ===========================================================================
set -e
set -u

DATA=/var/www/data
mkdir -p "$DATA" 2>/dev/null || true

if ! ( : > "$DATA/.write-test" ) 2>/dev/null; then
  echo "shaarli: $DATA is not writable by uid $(id -u)" >&2
  exit 1
fi
rm -f "$DATA/.write-test"

PHP=php84
command -v "$PHP" >/dev/null 2>&1 || PHP=php

cd /var/www/shaarli
exec "$PHP" -S 0.0.0.0:8080 -t /var/www/shaarli
