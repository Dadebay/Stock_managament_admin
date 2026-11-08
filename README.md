# Kümüş Stock Admin

A Flutter Web panel for Kümüş staff to manage inventory, products, orders, purchases, expenses, clients, and reports. Staff sign in with a username and password. The interface includes Turkmen and Russian text, and administrators see additional management actions. The backend remains responsible for enforcing permissions and financial values.

## Run locally

Use Flutter 3.47.8 or another compatible stable version, then run:

```sh
flutter pub get
flutter run -d chrome
```

The current development default is the legacy API origin `http://216.250.11.255:9000`. To use an HTTPS backend, set its public origin at build or run time:

```sh
flutter run -d chrome --dart-define=STOCK_API_ORIGIN=https://your-api-host
```

The origin is compiled into browser code. Never use it for secrets. The API paths are defined in `lib/app/product/constants/api_constants.dart`. Authentication, product images, orders, purchases, clients, and reports all depend on that backend.

## Check and build

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --wasm --release
```

The WASM build and range loader are required by the current deployment setup. `./deploy/deploy_web.sh build` prepares a local build only; `upload` changes the live site. See [deployment instructions](deploy/README.md) before any upload. No upload is part of the checks above.

## Distribution and operations

This repository contains a **web panel only**. It has no Android or iOS project, Google Play listing, signed APK, or App Store listing. The currently documented [web host](http://216.250.11.255/) responds over HTTP; it is not a secure production login endpoint. Before staff use, the owner must provide HTTPS for the panel and API, verify CORS and backend permissions, and move browser authentication away from JavaScript-readable storage to a server-managed secure session. Do not enter real credentials on the HTTP site.

The account API currently supplies readable passwords to the panel for editing. The panel masks them in its list and excludes them from Excel exports, but the backend owner must stop storing and returning readable passwords and provide a separate password-reset operation. A credential formerly embedded in the client source also needs rotation and removal from Git history by the repository owner.

Deployment, backend backups, rollback, credential rotation, and monitoring are controlled on the server. Their owners and secure storage locations are not present in this repository and must be confirmed before a production rollout. No new GitHub Release is claimed until the exact built source is deployed and verified.
