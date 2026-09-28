# Safety Observation coding guide

- Target Android with Flutter and Dart. The first release works offline without a server, automatic sync, or Internet permission.
- Put every complete screen in its own `*_screen.dart` file under its feature's `presentation/` directory. Share small widgets and colors instead of duplicating them.
- Keep visible copy outside widgets so English can be localized later.
- Model and store a complete observation report independently of screen layout. Never store employee information, reports, photos, signatures, or secrets in Git.
- The Figma file is the visual source. Match each screen's actual frame; use downloaded permanent local assets, never short-lived Figma URLs or screen screenshots as UI assets.
- Do not add a package merely for a small convenience. Check Flutter/Dart compatibility before adding any package and commit the resulting `pubspec.lock` for this application.
- Do not claim a UI or workflow is implemented while it is a placeholder. Run `flutter analyze` and a device build after Flutter SDK and platform folders are available.
