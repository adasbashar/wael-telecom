# Wael Telecom (Android)

Inventory & price-lookup app for the Wael Telecom mobile store: barcode scanning, items without barcodes, USD + SYP prices, stock, sales and backups.

The app itself is `app/src/main/assets/index.html`, wrapped in a WebView.

**Getting the APK:** every push to `main` builds it automatically (GitHub Actions). Download it from the `apk` branch (`WaelTelecom.apk`) or from the latest run under the Actions tab → Artifacts.

**Updating:** edit `app/src/main/assets/index.html`, bump `versionCode` in `app/build.gradle`, push. Installing the new APK over the old one keeps all data (same signing key: `app/wael-telecom.keystore` — keep it, don't delete it).
