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

## Why WASM is never pre-compressed

`main.dart.wasm` is fetched in 64 KB byte ranges by `web/wasm_range_loader.js`
(the network path resets large responses). If a `main.dart.wasm.gz` sits next
to it, `gzip_static` answers those Range requests with gzipped bytes and the
browser dies on them:

```
GET main.dart.wasm  net::ERR_CONNECTION_RESET 206 (Partial Content)
Uncaught (in promise) TypeError: Failed to fetch
```

`curl -H 'Accept-Encoding: identity'` never reproduces it — only a real browser
does, because it always asks for gzip. So the deploy script skips `*.wasm` when
gzipping, deletes any stale `*.wasm.gz`, and verifies the range response with a
browser-like `Accept-Encoding` header. If you ever see a `Content-Encoding`
header on that 206, either a `.gz` came back or nginx compressed it; the
belt-and-braces server-side fix is:

```nginx
location = /main.dart.wasm {
    gzip off;
    gzip_static off;
}
```

## Overriding the target

```bash
STOCK_SSH_TARGET=ubuntu@some-other-host STOCK_REMOTE_DIR=/some/other/path ./deploy/deploy_web.sh
```
