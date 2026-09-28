# Safety Observation

Flutter application for Android safety observations. Version one is offline first and has no server synchronization.

## Current state

The repository contains an app entry point, the Home screen's separate Dart file, shared theme/text, and the report domain model. **The Home layout is still a placeholder**, and data is not yet persisted. Progress is tracked in [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md).

The Figma file has 15 frames. Each will be implemented in a separate screen file under its feature directory. No short-lived Figma asset URLs will be used at runtime.

## Run locally

Install Flutter SDK, clone this repository, then run from its root:

```bash
flutter create --project-name safety_observation --platforms android .
flutter pub get
flutter analyze
flutter run
```

`flutter create` supplies the standard Android platform files, which are not yet committed. Review generated changes before committing them. The current project has no third-party Dart packages.
