# My Little Planner

A Flutter student planner with a local preview and an optional Firebase account/data layer.

## Local preview

Flutter and Dart versions, Android build configuration, and platform SDK settings remain those already configured in the project.

```powershell
C:\Flutter\flutter\bin\flutter.bat run -d emulator-5554
```

Without Firebase settings, the app stays in preview mode. Preview content is in-memory and is not sent anywhere.

## Firebase setup

Firebase is optional until a Firebase project is configured. Create a project, enable Email/Password in Firebase Authentication, create Firestore and Storage, then copy `.env.example` to the ignored `firebase.env.json` and fill in the project’s client configuration values. The Firebase client API key and app ID identify the public client; never put service-account keys, Admin SDK credentials, or other privileged secrets in the app.

Pass the configuration at build/run time:

```powershell
C:\Flutter\flutter\bin\flutter.bat run -d emulator-5554 --dart-define-from-file=firebase.env.json
```

Deploy `firestore.rules`, `firestore.indexes.json`, and `storage.rules` with the Firebase CLI after reviewing them for the target project. User profiles and records are placed under `users/{uid}` and access is checked against the authenticated UID. The authentication SDK persists its session. Attachments are stored privately under `users/{uid}/attachments/`, with a 20 MiB size limit and an allowlist of content types.

For local emulator use, set `FIREBASE_USE_EMULATORS` to `"true"` in `firebase.env.json`, start Firebase Auth, Firestore, and Storage emulators using `firebase.json`, and set `FIREBASE_EMULATOR_HOST` to the host reachable from the app (Android emulator default: `10.0.2.2`; desktop/web: `127.0.0.1`).

The record envelope and collection catalog are described in [docs/firebase-data-model.md](./docs/firebase-data-model.md). Firestore is document-based: references are stored as IDs and enforced by repositories/rules rather than SQL foreign keys. `schemaVersion` is stored on user profiles; deployable Firestore rules and indexes are the schema-change artifacts.

## Validation

```powershell
C:\Flutter\flutter\bin\flutter.bat analyze
C:\Flutter\flutter\bin\flutter.bat test
npx --yes firebase-tools emulators:exec --only auth --project demo-student-planner "npm run test:auth --prefix firebase-tests"
npx --yes firebase-tools emulators:exec --only firestore --project demo-student-planner "npm run test:rules --prefix firebase-tests"
npx --yes firebase-tools emulators:exec --only storage --project demo-student-planner "npm run test:storage --prefix firebase-tests"
```

Firebase emulator tests require Node.js and Java 21 (set `JAVA_HOME` to a JDK 21 installation if another Java version is the default). The account and profile flows cannot reach your Firebase project until its client configuration is supplied and the rules are deployed.
