# Web panel deployment

The admin panel is currently served straight off `216.250.11.255` (no domain,
no HTTPS) — nginx site `/etc/nginx/sites-available/webstock`, root
`/home/ubuntu/web`. The build living there right now is from **May 5** — none
of the recent work is live until you deploy.

## One-time nginx change

The current config only has `gzip on;`, which recompresses `main.dart.js`
(3+ MB) on every single request. Pre-compressing once at deploy time and
serving the ready-made `.gz` file is much cheaper. On the server:

```bash
sudo nano /etc/nginx/sites-available/webstock
```

Add `gzip_static on;` right next to the existing `gzip on;` line (both can
stay — `gzip_static` serves the pre-built `.gz` when present, the dynamic
`gzip on;` still covers anything that doesn't have one). Then:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

If `nginx -t` complains `gzip_static` is an unknown directive, the installed
nginx package doesn't have the module — check with
`nginx -V 2>&1 | grep -o gzip_static` and if it's missing, install
`nginx-full` (or `nginx-extras`) instead of the base `nginx` package.

## Every deploy

```bash
./deploy/deploy_web.sh
```

This builds (`flutter build web --release`), gzips the JS/WASM/CSS/HTML/fonts
next to their originals, `rsync --delete`s the whole `build/web/` to
`/home/ubuntu/web` on the server, and checks that `Content-Encoding: gzip`
actually comes back afterward.

Run `./deploy/deploy_web.sh build` and `./deploy/deploy_web.sh upload`
separately if you ever need to inspect the build before shipping it.

Manual check any time:

```bash
curl -sI -H 'Accept-Encoding: gzip' http://216.250.11.255/main.dart.js | grep -i 'content-encoding\|content-length'
```

## Overriding the target

```bash
STOCK_SSH_TARGET=ubuntu@some-other-host STOCK_REMOTE_DIR=/some/other/path ./deploy/deploy_web.sh
```
