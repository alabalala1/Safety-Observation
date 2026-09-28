# Implementation status

## In place

- Flutter app entry point and Material theme.
- Figma Home color tokens.
- Central English strings, including offline-only wording.
- One file for the Home screen entry point.
- Typed report model and local repository contract.

## Next implementation milestones

1. Obtain and commit the Figma SVG assets and font where licensed; implement the Home frame precisely in `home_screen.dart`.
2. Implement each remaining Figma frame in a separate screen file and connect navigation and validation.
3. Choose one compatible local database package, implement autosave, search, and attachment handling.
4. Add PDF, `.safety` transfer, backup/restore, and device verification.

The current Home is an entry-point placeholder, not the finished design. Flutter SDK and Android platform files are not available in the current cloud environment, so analysis and a device build are pending.
