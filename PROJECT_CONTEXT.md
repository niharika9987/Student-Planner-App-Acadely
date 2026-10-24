# Student Planner — Current Project Context

**Product name:** “My Little Planner” in the current app; final branding remains unconfirmed.  
**Project type:** Cross-platform Flutter application with a mobile-first layout and responsive navigation.  
**Status:** Functional UI prototype with an optional Firebase authentication and persistence layer. Firebase is not configured until a project-specific `firebase.env.json` is supplied.

## Stack and structure

- Dart/Flutter, managed with Flutter Pub; the existing Dart SDK constraint and platform build files are preserved.
- Entry point: `lib/main.dart`; app shell/theme/navigation: `lib/app/planner_app.dart`.
- Feature screens live under `lib/features/`; shared preview task state is `lib/data/planner_store.dart`; common design tokens/widgets are in `lib/ui/planner_design.dart`.
- Five main destinations use mobile bottom navigation and a wide-screen navigation rail. Material routes provide secondary screens.
- Firebase Auth, Cloud Firestore, and Firebase Storage are the selected remote services. Firebase initialization is opt-in using compile-time values from the ignored `firebase.env.json`; no service-account or Admin credentials are embedded.
- User profiles are stored at `users/{uid}`. User-owned records use `users/{uid}/{collection}/{recordId}`. Cloud rules and the record catalog are documented in `docs/firebase-data-model.md`.

## Current behavior and boundaries

- When Firebase values are absent, the app explicitly runs the local preview. Preview content is in-memory and does not send credentials or persist across restart.
- With Firebase configured, email/password registration, login, password reset, auth-session observation, profile onboarding/editing, logout, and reauthenticated account deletion use Firebase services.
- Authenticated users are routed through profile completion before entering the planner. Preview task examples are not loaded into authenticated stores.
- Authenticated task creation, editing, completion, deletion, and loading are wired to per-user Firestore task documents. The generic user-scoped repository/catalog provides a boundary for other record types; academic, Vault, habit, and analytics screens still largely contain preview content and are not all backed by records yet.
- File attachment upload has a private Firebase Storage adapter with MIME/size validation. Upload controls and Firestore attachment metadata workflows are not yet integrated into the Vault screens.
- Account deletion reauthenticates, deletes enumerated user collections and attachment paths, deletes the profile, then deletes the Auth user. Keep its collection list aligned with `PlannerCollection`.
- AI, university/LMS, calendar, and shared-group services are not connected.

## Security and reliability

- `firestore.rules` scopes profile and record access to the authenticated UID, restricts fields and task values, and disallows client-authored audit entries. `storage.rules` scopes file access by UID, MIME type, and a 20 MiB maximum.
- `firebase-tests/` exercises Auth lifecycle, Firestore profile/task ownership and validation, and Storage attachment access against the Firebase emulators.
- Firestore uses document references rather than SQL foreign keys. Repositories must validate related-record ownership/existence; additional per-collection rules are required before enabling writes for all catalog types.
- Firebase rules/emulator deployment and real project auth flows cannot be validated until Firebase Emulator Suite or project configuration is available.
- Firebase public client configuration is project-specific, not a privileged secret. Never commit service-account keys or Admin credentials.
- `android/local.properties` remains machine-local and must not be shared.

## Validation and next work

- Flutter widget tests and analysis cover the current UI and local task flows; Firebase emulator rules tests cover the access policy when run with the configured emulator command.
- Run `C:\Flutter\flutter\bin\flutter.bat analyze` and `C:\Flutter\flutter\bin\flutter.bat test`.
- Run the documented Auth, Firestore, and Storage emulator commands in `README.md` separately for provider and Rules tests.
- Next: configure a Firebase project, run the emulators, complete the data validation/rules for each entity before enabling writes, connect academic/Vault/life screens to repositories, and test profile/task persistence on an actual configured project.
