#!/usr/bin/env bash
#
# Build the Stock Management admin web app (WASM) and ship it to the server.
#
# WASM build is required, not optional: the network path to this server runs
# the response body of large *.js files through some kind of content
# inspection that resets the TCP connection partway through (confirmed by
# testing plain-text, binary, and gzip payloads of identical size — only
# main.dart.js triggered it, .wasm files never did). Serving the app's main
# code as a WebAssembly binary instead of JS text routes around it entirely.
#
# gzip precompression is required because nginx's gzip_static serves the
# .gz files this script writes.
#
# The production network can close a large WASM response partway through.
# wasm_range_loader.js fetches main.dart.wasm as 64 KB HTTP byte ranges, which
# are reliably delivered. Keep it in the generated output even if a future
# Flutter build changes how it copies files from web/.
#
# Usage:
#   ./deploy/deploy_web.sh build     # build only
#   ./deploy/deploy_web.sh upload    # upload only (needs a prior build)
#   ./deploy/deploy_web.sh           # both
#

set -euo pipefail

SSH_TARGET="${STOCK_SSH_TARGET:-ubuntu@216.250.11.255}"
REMOTE_DIR="${STOCK_REMOTE_DIR:-/home/ubuntu/web}"
BUILD_DIR="build/web"
WASM_RANGE_LOADER="web/wasm_range_loader.js"

cd "$(dirname "$0")/.."

build() {
    echo "==> Building (wasm)"
    flutter build web --wasm --release

    echo "==> Installing WASM range loader"
    test -f "$WASM_RANGE_LOADER"
    cp "$WASM_RANGE_LOADER" "$BUILD_DIR/wasm_range_loader.js"
    if ! grep -q 'wasm_range_loader.js' "$BUILD_DIR/index.html"; then
        perl -0pi -e 's{(<script src="flutter_bootstrap\.js" async></script>)}{<script src="wasm_range_loader.js"></script>\n  $1}' "$BUILD_DIR/index.html"
    fi

    echo "==> Compressing"
    find "$BUILD_DIR" -type f \
         \( -name '*.js' -o -name '*.mjs' -o -name '*.wasm' -o -name '*.json' \
         -o -name '*.css' -o -name '*.html' -o -name '*.ttf' \
         -o -name '*.otf' -o -name '*.svg' \) \
         -exec gzip -9 -k -f {} +

    echo "==> Build size"
    du -sh "$BUILD_DIR"
}

upload() {
    echo "==> Uploading to $SSH_TARGET:$REMOTE_DIR"
    rsync -avz --delete "$BUILD_DIR/" "$SSH_TARGET:$REMOTE_DIR/"

    echo "==> Verifying a 64 KB WASM byte range is actually served"
    curl -sS -o /dev/null -w "HTTP:%{http_code} size:%{size_download}\n" --max-time 30 \
        -H 'Accept-Encoding: identity' -H 'Range: bytes=0-65535' \
        "http://216.250.11.255/main.dart.wasm" || echo "WARNING: verification request failed"

    echo "==> Done: http://216.250.11.255/"
}

case "${1:-all}" in
    build)  build ;;
    upload) upload ;;
    all)    build; upload ;;
    *) echo "Usage: $0 [build|upload]"; exit 1 ;;
esac
