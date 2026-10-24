# Student Planner — Implementation Roadmap

This roadmap preserves the existing Flutter/Dart stack and sequences work toward a production-quality, mobile-first planner. Firebase is now the selected account/data provider; product branding and optional external providers remain open.

## Phase 0 — Product decisions and project foundation

- Confirm product name, initial supported platforms, offline expectations, data retention/privacy requirements, and whether accounts or multi-device sync are in scope.
- Configure the selected Firebase project and define release platform support, offline expectations, and account/data retention policy.
- Replace starter README content, application labels, and example Android application ID when branding/package identity are confirmed.
- Establish feature-first folders, shared theme/tokens, app navigation, error handling, and dependency composition while preserving the current visual direction.
- Replace the stale counter test with tests for the real app and resolve the analyzer failure and task-tile Material assertion.
- Agree on accessibility and responsive layout targets and add a small UI test baseline.

**Exit evidence:** App starts with real destinations; analyzer and baseline tests pass; supported platform and persistence decisions are documented.

## Phase 1 — Planner data foundation and everyday tasks

- Define typed models for tasks, due dates, priority, completion, and task categories; add validation and stable identifiers.
- Implement repository-backed task creation, editing, completion, deletion, and filtering.
- Keep preview state local and persist authenticated tasks through the Firebase per-user repository; version the profile and record schema.
- Build Today and task-list screens with empty, loading, and error states; ensure progress reflects persisted data.

**Exit evidence:** Task operations survive restart, behave correctly at date boundaries, and have unit/widget coverage.

## Phase 2 — University and semester planning

- Add semesters, courses, class meetings, assignments, and grading/assessment records with relationships to tasks.
- Build course and semester setup plus an academic schedule and deadline view.
- Add manual attendance sessions and course attendance summaries; document the calculation policy and allow correction of entries.
- Add academic performance summaries only after grading scales and weighting rules are configurable or explicitly defined.

**Exit evidence:** A student can manage a semester, course schedule, deadlines, attendance, and recorded results without relying on hard-coded sample data.

## Phase 3 — Daily planning, routines, and reminders

- Add a day/week planner that combines tasks, classes, due dates, and user-entered available time.
- Implement explainable prioritization and deadline warnings; keep suggestions deterministic before introducing AI.
- Add habits, goals, and recurring routines with completion history.
- Add local notifications and user-controlled reminder preferences where supported by target platforms.

**Exit evidence:** Daily views handle overdue, recurring, completed, and rescheduled items consistently; reminders respect permission and preference states.

## Phase 4 — Notes, study materials, and revision

- Add notes linked to courses, assignments, and study sessions.
- Support organizing study materials and attachments with explicit local storage and backup limits.
- Add revision planning and lightweight study-session tracking; keep imported or generated content traceable to its source.

**Exit evidence:** Notes/materials remain associated with the right academic entities and are covered by persistence and attachment tests.

## Phase 5 — Insights and optional motivation features

- Add analytics for task completion, study time, attendance, and academic progress using transparent definitions.
- Add optional streaks, milestones, or rewards only if user research supports them; make gamification dismissible and avoid punitive defaults.
- Add data export and clear empty/insufficient-history states.

**Exit evidence:** Metrics can be traced to stored records, and optional gamification does not block core planning.

## Phase 6 — Accounts, synchronization, AI, and university integrations

Proceed only for integrations approved for the product:

- Complete the Firebase Auth/profile/task foundation, configure a real project, validate rules with emulators, and connect remaining records. Define offline edits, conflict resolution, recovery, and deletion before release.
- Add an AI service boundary for study assistance and planning. Use a trusted server-side integration for provider credentials, obtain user consent, minimize shared data, and make generated suggestions reviewable.
- Add LMS/university and calendar adapters only for selected providers and supported permissions; preserve manual entry and graceful behavior when a provider is unavailable.
- Add remote push infrastructure only if on-device notifications are insufficient.

**Exit evidence:** Provider-specific flows have consent/error handling, data minimization, security review, and integration tests; core functionality still works without optional services.

## Phase 7 — Production hardening and release

- Validate Android/iOS behavior on supported device sizes, orientations, and accessibility settings; validate web/desktop only if included in release scope.
- Add accessibility semantics/contrast checks, localization readiness, performance checks, and coverage for critical flows.
- Review privacy/security boundaries, storage protection, network behavior, dependency health, and backup/deletion requirements.
- Configure production application identifiers, icons, signing, versioning, build automation, crash/error reporting policy, and release documentation.

**Exit evidence:** Reproducible release builds, passing automated quality gates, documented support matrix, and no placeholder signing/identity settings in release configuration.

## Proposed implementation file map

### Authentication and data foundation status

Firebase Auth, the student profile, per-user task persistence, generic Firestore record catalog, private attachment upload adapter, Firestore/Storage Rules, and emulator rule tests are scaffolded. Real project configuration is intentionally absent; academic, Vault, habits, goals, and analytics are not yet connected to persistence.

The precise files and package choices depend on Phase 0 decisions. A likely shape is:

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme/
  core/
    storage/
    notifications/
    widgets/
  features/
    tasks/{data,domain,presentation}/
    academics/{data,domain,presentation}/
    planner/{data,domain,presentation}/
    habits/{data,domain,presentation}/
    notes/{data,domain,presentation}/
    analytics/{data,domain,presentation}/
    study_assistant/{data,domain,presentation}/
test/
  features/
  app/
```

Likely existing files to modify over the phases:

- `lib/main.dart` — reduce to bootstrap as app setup is extracted.
- `test/widget_test.dart` — replace the mismatched generated counter test with app behavior tests.
- `pubspec.yaml` and `pubspec.lock` — add only dependencies justified by selected persistence, routing, state, notifications, or integration needs.
- `README.md` — document the actual product, setup, supported platforms, and test commands.
- Platform manifests/configuration under `android/`, `ios/`, and `web/` — update identity, permissions, icons, signing, and web metadata only as approved features require.

New local database schemas/migrations, backend/API schemas, and provider-specific configuration should be created only after the corresponding Phase 0/Phase 6 decisions. Do not commit secrets or machine-local SDK configuration.
