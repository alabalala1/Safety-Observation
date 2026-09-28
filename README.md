# Safety Observation

Offline Flutter application for Android safety observations. The 15 screens from Figma are implemented in separate Dart files and use local SVG assets.

## Features

- SQLite stores reports and an optional employee profile on the device. Form edits are saved after a short pause; completing or saving a draft commits its status.
- History supports status filters, search, details, editing, duplicating, and deletion.
- Camera/gallery photos and a drawn supervisor signature are copied into application storage and included in report exports.
- Export a report as PDF or a `.safety` file, import a `.safety` file, and export or restore a `.sbackup` archive from Settings. Existing report IDs are retained during restore.
- No account, remote service, or server synchronization. Backups and exported reports contain employee information and media; store shared files securely.

## Run locally

Install Flutter SDK, clone the repository, then run:

```bash
flutter create --project-name safety_observation --platforms android --no-pub .
flutter pub get
flutter analyze lib
flutter run
```

The standard Android platform scaffold is generated because it is not tracked here. Dependencies are pinned in `pubspec.yaml` and `pubspec.lock`.

## Android build on GitHub

Every push triggers [Android debug build](.github/workflows/android-build.yml). It installs Flutter 3.47.0, generates Android platform files, resolves dependencies, analyzes `lib`, and builds a debug APK. Open a successful run in the **Actions** tab and download **safety-observation-debug-apk** under **Artifacts**. Artifacts are retained for 14 days. A signed release build and device visual check are still required before distribution.
