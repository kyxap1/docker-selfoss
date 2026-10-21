#!/bin/sh
# Updates single sources through the same endpoint the UI uses and prints
# unread count, error and lastentry per source. Usage: smoke.sh [id ...]
BASE=${BASE:-http://localhost:8888}
IDS=${*:-36 18 22 43}

state() {
  python3 -I -c '
import json, sys, urllib.request
base, sid = sys.argv[1], int(sys.argv[2])
get = lambda p: json.load(urllib.request.urlopen(base + p, timeout=60))
src = next(s for s in get("/sources/list") if s["id"] == sid)
unread = next(s["unread"] for s in get("/sources/stats") if s["id"] == sid)
print("%-18s unread=%-4s lastentry=%s error=%s" % (src["title"], unread, src["lastentry"], (src["error"] or "none")[:70].replace("\n", " ")))
' "$BASE" "$1"
}

for id in $IDS; do
  echo "== source $id"
  printf 'before: '; state "$id"
  curl -sS -m 120 -X POST -o /dev/null -w 'update: HTTP %{http_code} in %{time_total}s\n' "$BASE/source/$id/update"
  printf 'after:  '; state "$id"
done
