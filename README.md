# Safety Observation

Flutter application for Android safety observations. Version one is offline first and has no server synchronization.

## Current state

The repository contains an app entry point, the Home, Observation Type, and Basic Info screens in separate Dart files, local Figma SVG assets, shared theme/text, and the report domain model. The draft is not yet persisted; further screens and actions are still being implemented. Progress is tracked in [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md).

The Figma file has 15 frames. Each is mapped to a separate screen file in [docs/DESIGN_MAPPING.md](docs/DESIGN_MAPPING.md). No short-lived Figma asset URLs are used at runtime.

## Run locally

Install Flutter SDK, clone this repository, then run from its root:

```bash
flutter create --project-name safety_observation --platforms android .
flutter pub get
flutter analyze
flutter run
```

`flutter create` supplies the standard Android platform files, which are not yet committed. Review generated changes before committing them. The only third-party package currently declared is `flutter_svg 2.0.17` for the exact local icons exported from Figma. The Dart SDK minimum is 3.4, matching that package's published requirement.
