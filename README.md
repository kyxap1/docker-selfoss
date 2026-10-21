# docker-selfoss

[selfoss](https://selfoss.aditu.de/) 2.19 on Alpine with nginx, php-fpm and s6.
Derived from [radek-sprta/docker-selfoss](https://gitlab.com/radek-sprta/docker-selfoss),
which is pinned to Alpine 3.16 and PHP 8.0.

## Changes from upstream

- Base is Alpine 3.24; the PHP version is a build argument (`PHP`, default `84`).
- Version-independent paths: `php`/`php-fpm` symlinks and `/etc/selfoss/php-fpm.conf`,
  so moving to another PHP is a one-argument change.
- `s6-svscan` is resolved through `PATH` (it moved to `/usr/bin`).
- The healthcheck uses `127.0.0.1`: busybox `wget` resolves `localhost` to `::1`,
  but nginx listens on IPv4 only.

## Build

    docker build -t kyxap/selfoss --build-arg PHP=84 .

Rebuild with `--no-cache` to pick up fixed Alpine packages. Alpine publishes packages per
architecture, so x86_64 can be ahead of arm64.

## PHP versions

Tested with selfoss 2.19: 8.3 and 8.4 work. 8.5 breaks sources that use the fulltext
spout (`tidy_repair_string(): ... option "input-encoding" does not accept ...`).
selfoss 2.19 is the last release; 2.20 is unreleased and requires PHP 8.2+.

## Test

`test/` runs an image against a copy of a real selfoss data dir: it deletes the newest
items of two sources, updates single sources through `POST /source/<id>/update` and
through `cliupdate`-style CLI bootstrap, and checks that the items come back with no PHP
warnings at `E_ALL`. Source ids in the scripts belong to the author's feed list.

    DATA_ORIG=/path/to/pristine/selfoss/data test/run-variant.sh 84

The data dir holds `config.ini` with credentials and must not be committed
(`selfoss-data.*` is ignored). The cron service is replaced by a stub during tests.
