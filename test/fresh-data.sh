#!/bin/sh
# Recreates selfoss-data.new from a pristine copy of the selfoss data dir with a
# test-only config: local base_url, DEBUG logging, no login.
# The pristine copy is $DATA_ORIG (default: selfoss-data.orig) and is never modified.
ROOT=$(cd "$(dirname "$0")/.." && pwd)
ORIG=${DATA_ORIG:-$ROOT/selfoss-data.orig}
rm -rf "$ROOT/selfoss-data.new"
cp -R "$ORIG" "$ROOT/selfoss-data.new"
sed -i.bak -E \
  -e 's|^[[:space:]]*base_url[[:space:]]*=.*|base_url=http://localhost:8888/|' \
  -e 's|^[[:space:]]*logger_level[[:space:]]*=.*|logger_level=DEBUG|' \
  -e 's|^[[:space:]]*username[[:space:]]*=.*|username=|' \
  -e 's|^[[:space:]]*password[[:space:]]*=.*|password=|' \
  "$ROOT/selfoss-data.new/config.ini"
rm "$ROOT/selfoss-data.new/config.ini.bak"
