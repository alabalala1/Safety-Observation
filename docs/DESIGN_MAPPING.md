# Figma screen map

Design file: `eNLkUWaaTxCcfWNCEK4X3P`, page `0:1`. Each frame becomes one Dart screen file. A file is created only when its screen is implemented; an empty placeholder must not be treated as complete.

| Figma frame | Screen file | State |
| --- | --- | --- |
| `2:4` home-screen | `lib/features/home/presentation/home_screen.dart` | UI implemented; data actions pending |
| `2:151` observation-type-screen | `lib/features/observations/presentation/observation_type_screen.dart` | Selection implemented; Continue target pending |
| `2:236` basic-information-screen | `lib/features/observations/presentation/basic_information_screen.dart` | UI and Area entry; local saving and next step pending |
| `4:4` employee-information-screen | `lib/features/observations/presentation/employee_information_screen.dart` | UI and input navigation implemented; no profile prefill yet |
| `5:5` observed-event-screen | `lib/features/observations/presentation/observed_event_screen.dart` | UI and description input implemented; photo capture and disk saving pending |
| `5:71` potential-hazard-screen | `lib/features/observations/presentation/potential_hazard_screen.dart` | UI and description input implemented; photo capture and disk saving pending |
| `5:143` action-taken-screen | `lib/features/observations/presentation/action_taken_screen.dart` | UI and text input implemented; next screen and disk saving pending |
| `6:5` safety-categories-screen | `lib/features/observations/presentation/safety_categories_screen.dart` | Pending |
| `6:120` safe-unsafe-actions | `lib/features/observations/presentation/safe_unsafe_actions_screen.dart` | Pending |
| `6:163` risk-ranking | `lib/features/observations/presentation/risk_ranking_screen.dart` | Pending |
| `6:215` supervisor-notification | `lib/features/observations/presentation/supervisor_notification_screen.dart` | Pending |
| `6:268` attachments | `lib/features/observations/presentation/attachments_screen.dart` | Pending |
| `6:318` review-and-save | `lib/features/observations/presentation/review_and_save_screen.dart` | Pending |
| `7:5` reports-history | `lib/features/reports/presentation/reports_history_screen.dart` | Pending |
| `7:131` report-details | `lib/features/reports/presentation/report_details_screen.dart` | Pending |

## Design decisions for version one

- Use the native Android status bar rather than the iOS status bar drawn in Figma.
- Replace hardcoded site, clock, counts, and build number with real state or omit them until available.
- Do not show the Home notice promising automatic LTE/Wi-Fi sync, or the `synced forms` label. The specification defines file exchange and local backup, with server sync reserved for a future release.
- Keep text in a localization layer and use local, durable icon/font files from the design rather than temporary Figma URLs.
