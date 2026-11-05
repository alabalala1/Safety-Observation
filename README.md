# Safety Observation

Offline Flutter application for Android safety observations. The 15 screens from Figma are implemented in separate Dart files and use local SVG assets.

## Features

- SQLite stores reports and an optional employee profile on the device. Form edits are saved after a short pause; completing or saving a draft commits its status.
- History supports status filters, search, details, editing, duplicating, and deletion.
- Camera/gallery photos and a drawn supervisor signature are copied into application storage and included in report exports.
- Export a report as PDF or a `.safety` file, import a `.safety` file, and export or restore a `.sbackup` archive (reports, media, and profile) from Settings. Existing report IDs are retained during restore.
- No account, remote service, or server synchronization. Backups and exported reports contain employee information and media; store shared files securely.
- Device role is activated offline with a generated employee or supervisor code. Employees submit report files for review; supervisors approve with a drawn signature or return them with notes. See `tools/generate_role_codes.py` to issue pilot codes.

Generate role activation codes from the repository root with Python 3:

```powershell
python tools/generate_role_codes.py EMP --count 10
python tools/generate_role_codes.py SUP --count 3
```

Pilot activation codes only separate app workflows. The shared verification key is bundled in the app and generator; this is not a secure identity credential. Replace it with a signed-code design before relying on roles for authorization.

## Run locally

Install Flutter SDK, clone the repository, then run:

```bash
flutter create --project-name safety_observation --platforms android --no-pub .
flutter pub get
flutter analyze lib
flutter run
```

Native Android, iOS, and web scaffolds are generated during builds. Platform icons are provided in `safety-observation-icons/` and installed into each generated platform by `.github/scripts/install_platform_icons.py`; the 512 px Play Store image is also kept in `assets/app_icons/android/`. Dependencies are pinned in `pubspec.yaml` and `pubspec.lock`.

## Android release builds on GitHub

The [Android release workflow](.github/workflows/android-build.yml) runs on each push and can also be started manually from **Actions → Android release APKs → Run workflow**. It builds three small, signed release APKs: `arm64-v8a`, `armeabi-v7a`, and `x86_64`. Their Android application ID is `com.alabalala1.safety_observation`, and the launcher name is **Safety Observation**. Keep the application ID and signing key unchanged for future app updates. Download the `safety-observation-signed-apks` artifact from a successful run. Each APK installs on devices with the matching CPU architecture.

### Configure the persistent signing key once

Android accepts an update only when it has the same application ID and signing certificate as the installed app. Keep the upload keystore safe and reuse it for every build. Do not commit the keystore or its passwords.

Create a keystore locally (keep the alias and passwords you choose):

```powershell
keytool -genkeypair -v -keystore safety-observation-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias safety-observation
[Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path .\safety-observation-upload.jks)))
```

In the GitHub repository, open **Settings → Secrets and variables → Actions** and add these repository secrets. Set `ANDROID_KEYSTORE_BASE64` to the full Base64 output from the second command:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`

Back up the `.jks` file securely. If it is lost, future APKs cannot update installations signed with that key. The workflow sets an increasing Android build number for each run so later APKs can be installed as updates.
