#!/bin/sh
# Runs the image for PHP version <V> (default tag selfoss-lab:php<V>, override with
# IMAGE, and PLATFORM for another architecture) on a fresh copy of the data dir
# and exercises it. Usage: run-variant.sh 84
# Leaves the container (selfoss-t<V>) running; remove it with docker rm -f.
V=$1
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$HERE/..
C=selfoss-t$V

docker rm -f "$C" >/dev/null 2>&1
"$HERE/fresh-data.sh"
docker run -d --name "$C" ${PLATFORM:+--platform "$PLATFORM"} -p 127.0.0.1:8888:8888 -e LOG_TO_STDOUT=true \
  -v "$ROOT/selfoss-data.new:/selfoss/data" \
  -v "$HERE/cron-stub.run:/services/cron/run:ro" \
  -v "$HERE/99-test.ini:/etc/php$V/conf.d/99-test.ini:ro" \
  "${IMAGE:-selfoss-lab:php$V}" >/dev/null

n=0
until curl -fsS -m 3 -o /dev/null http://localhost:8888/ 2>/dev/null; do
  n=$((n + 1))
  if [ "$n" -ge 45 ]; then echo "NOT READY"; docker logs "$C" 2>&1 | tail; exit 1; fi
  sleep 2
done
echo "ready after ~$((n * 2))s"
docker exec "$C" php -v | head -1

docker cp "$HERE/drop-latest.php" "$C:/tmp/"
docker cp "$HERE/update-single.php" "$C:/tmp/"
docker exec "$C" php /tmp/drop-latest.php
"$HERE/smoke.sh" 18 43 36 22

echo "-- cli (E_ALL):"
docker exec "$C" php -d error_reporting=-1 -d display_errors=1 /tmp/update-single.php 43 2>&1 | cut -c1-220 | tail -6
echo "-- web php errors (E_ALL):"
docker exec "$C" sh -c 'cut -c1-220 /tmp/php-errors.log 2>/dev/null | sed -E "s/^\[[^]]*\] //" | sort | uniq -c | sort -rn | head -8'
