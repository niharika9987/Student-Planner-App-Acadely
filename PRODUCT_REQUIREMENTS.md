# Product Requirements: [APP NAME]

> **Status:** Draft for product-owner review  
> **Product name:** To be confirmed  
> **Audience:** University students managing academic and personal responsibilities  
> **Baseline:** The current repository is a Flutter/Dart cross-platform prototype. See [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md).

## Scope Baseline

- **Discovery method:** User-provided product vision (modules A–J) reconciled against the repository state documented in `PROJECT_CONTEXT.md`.
- **Items discovered:** 10 requested product modules, covering account/onboarding, dashboard, academics, personal planning, intelligent planning, study materials, AI assistance, progress, career/campus, and settings/reliability.
- **Items in scope:** All 10 modules are specified below. Release priority differs: the MVP is deliberately narrower than the complete product vision.
- **Implemented baseline:** A single Flutter screen with three hard-coded tasks, in-memory completion toggles, a progress indicator, reminder copy, and navigation labels that do not open distinct screens. No listed end-user module is implemented beyond that prototype behavior.
- **Scope boundary:** This is a product specification, not a claim that planned capabilities exist and not an implementation commitment to ship every future integration. Items assigned to later releases require product/provider decisions before implementation.
- **Product decisions pending:** [NEEDS CLARIFICATION: confirm the final product name]; [NEEDS CLARIFICATION: decide whether account creation is mandatory or whether a local-only guest path is also required]; [NEEDS CLARIFICATION: confirm launch jurisdictions and applicable privacy/data-residency obligations].

## Product Summary and Principles

[APP NAME] is intended to give a university student one dependable place to manage courses, academic work, personal commitments, and study progress. It should reduce the effort of deciding what to do next, while keeping the student in control of their schedule and data.

Product principles:

1. **Student-controlled:** Never make a consequential schedule, academic record, or financial change without explicit confirmation.
2. **Useful offline:** Core records should remain accessible and editable without an active network connection; synchronize later when synchronization is enabled.
3. **Transparent:** Explain calculated attendance, performance, workload, and recommendations, including assumptions and data sources.
4. **Supportive:** Encourage progress without shame, coercive streaks, or guilt-based notifications.
5. **Accessible and inclusive:** Support assistive technologies, adjustable text, reduced motion, clear language, and usable touch targets.
6. **Optional intelligence:** AI and external institutional integrations enhance the planner but are not required for manual planning and recordkeeping.
7. **Privacy by default:** Collect and share only data needed for an enabled feature; provide user-accessible export and account/data deletion.

## User Scenarios & Testing

Stories below describe planned outcomes. Unless explicitly identified as prototype behavior, they are not currently implemented.

### US-001 — Set up my student planner (Priority: P1)

As a student, I want to establish my profile, academic context, and preferences so that the planner can organize my work around my actual semester.

**Why this priority:** A semester, subjects, schedule, and timezone are the context for useful academic planning.

**Independent test:** Create a profile, add a semester and subject, and view the saved context after restarting the app.

**Acceptance scenarios:**

1. **Given** a new user, **When** they create an account and enter their profile and academic year, **Then** the planner saves those details and identifies which setup sections remain optional.
2. **Given** a student who does not know all their timetable details yet, **When** they skip timetable setup, **Then** onboarding completes without invented classes and the student can add the schedule later.
3. **Given** a student who changes semester, timezone, or study goal, **When** they save updated details, **Then** future date displays and planning use the new settings without silently changing historical records.

### US-002 — See and manage today's workload (Priority: P1)

As a student, I want one calm daily view of classes, deadlines, planned study, and personal commitments so that I can start the day without checking multiple lists.

**Why this priority:** The daily dashboard is the main return point and consolidates information from other core modules.

**Independent test:** Seed a class, due and overdue tasks, an exam, a personal event, a habit, and a study block; verify the day view and complete a task.

**Acceptance scenarios:**

1. **Given** saved events and work for today, **When** the student opens My Day, **Then** items appear in time order where times exist, and undated overdue work is identified separately.
2. **Given** there is no scheduled work today, **When** the student opens My Day, **Then** the screen shows a useful empty state and offers an appropriate add action.
3. **Given** a task is completed from My Day, **When** the student returns to the dashboard, **Then** daily progress reflects the saved completion exactly once.
4. **Given** natural-language capture is enabled, **When** a student enters an ambiguous instruction, **Then** the app requests clarification before saving a guessed date or other consequential detail.

### US-003 — Organize semester academics (Priority: P1)

As a student, I want courses, schedules, assignments, and exams grouped by semester so that academic commitments and deadlines remain understandable.

**Why this priority:** Academic entities are central to the product and allow the dashboard to surface relevant work.

**Independent test:** Add a semester, subject, recurring class, assignment, and examination; verify they appear in the correct academic views and dashboard.

**Acceptance scenarios:**

1. **Given** a current semester, **When** the student adds or edits a subject and a weekly class, **Then** the timetable shows the saved days, times, timezone, and subject.
2. **Given** an assignment or exam with a deadline, **When** its due date approaches, **Then** it appears in the relevant upcoming and daily views and follows the student's reminder preferences.
3. **Given** an item belongs to a prior semester, **When** the student views the active semester, **Then** historical records remain available but are not treated as current work.

### US-004 — Track attendance and academic results (Priority: P1)

As a student, I want attendance and marks recorded by subject, with calculations that show their assumptions, so that I can understand progress and take corrective action.

**Why this priority:** Attendance requirements and performance affect academic decisions; calculations must be inspectable.

**Independent test:** Enter class sessions, attendance states, and assessment marks; compare displayed totals and forecasts with a documented example calculation.

**Acceptance scenarios:**

1. **Given** a course has a configured attendance threshold and recorded sessions, **When** the student opens its attendance view, **Then** attended, held, and required sessions are shown with the threshold and calculation basis.
2. **Given** a future class is included in an attendance forecast, **When** the forecast is displayed, **Then** it is clearly labeled as a projection rather than an actual attendance record.
3. **Given** a course has assessment marks and a grading policy, **When** the student views academic results, **Then** the displayed result identifies the applicable weights/scale and does not imply an official university GPA if the policy is incomplete.
4. **Given** a student corrects an entered mark or attendance record, **When** the value is saved, **Then** dependent summaries recalculate and the original value is not used as current data.

### US-005 — Balance personal responsibilities (Priority: P1)

As a student, I want personal tasks, routines, events, and goals kept distinct from academic work so that I can plan a balanced day.

**Why this priority:** The unified planner must support life outside classes without making personal and academic work indistinguishable.

**Independent test:** Create one task in each priority domain plus a habit, goal, and personal event; verify filters and day view.

**Acceptance scenarios:**

1. **Given** academic and personal tasks are due on the same day, **When** the student filters by domain, **Then** each filter shows only its own items and the combined daily view identifies each item's domain.
2. **Given** a habit recurs on selected days, **When** the student records today's completion, **Then** only today's occurrence is completed and prior history is preserved.
3. **Given** a reminder is disabled for personal events, **When** an event approaches, **Then** no notification is emitted for that event.

### US-006 — Create a realistic and recoverable study plan (Priority: P2)

As a student, I want the planner to estimate workload, fit tasks into available time, and help recover after missed work so that one disruption does not invalidate the whole plan.

**Why this priority:** Intelligent planning builds on trustworthy task, schedule, and availability data, so it follows the core records.

**Independent test:** Supply a schedule, estimated task durations, availability, and energy preferences; verify proposed blocks, explanations, and a repair after one block is missed.

**Acceptance scenarios:**

1. **Given** tasks have deadlines and estimated durations, **When** the student requests a plan, **Then** the plan fits only within stated available time and identifies any work it cannot fit.
2. **Given** the student reports low energy or declines a proposed block, **When** the plan is generated or repaired, **Then** the planner explains its revised choices and leaves the final schedule under student control.
3. **Given** the student misses a planned task, **When** they request schedule repair, **Then** the planner proposes alternatives without silently moving fixed classes, exams, or appointments.
4. **Given** workload history is insufficient, **When** the student views a forecast, **Then** the app indicates the limitation instead of presenting a false-precision estimate.

### US-007 — Keep and revise study materials (Priority: P2)

As a student, I want notes and resources organized by subject and searchable so that I can find learning materials when preparing for class or exams.

**Why this priority:** Academic Memory is valuable after the student can establish and organize their courses.

**Independent test:** Add notes and a supported document, tag and favorite them, search for text, and reopen a preview.

**Acceptance scenarios:**

1. **Given** materials are linked to a subject and tagged, **When** the student filters or searches, **Then** matching items are shown with their subject, title, and type.
2. **Given** a file type cannot be previewed, **When** the student opens the item, **Then** the app explains the limitation and preserves the file for supported sharing or external opening where possible.
3. **Given** flashcards or a quiz are generated from a source, **When** the student reviews an answer, **Then** the associated source material is available for verification.

### US-008 — Ask the Academic Copilot (Priority: P3)

As a student, I want optional AI assistance for organizing and studying so that I can turn instructions and materials into useful next steps without losing control of my records.

**Why this priority:** AI depends on reliable planner data, secure provider selection, privacy controls, and safe confirmation flows.

**Independent test:** Submit a natural-language task or a source document, inspect the proposed interpretation/output and citations, then accept, edit, or reject it.

**Acceptance scenarios:**

1. **Given** a natural-language request contains a date, duration, priority, and category, **When** it is parsed, **Then** each proposed field is shown for review before it becomes a saved task.
2. **Given** instructions are ambiguous, **When** the Copilot cannot identify a material detail, **Then** it asks a targeted question rather than inventing the missing detail.
3. **Given** the Copilot answers using uploaded materials, **When** it presents an academic answer, **Then** it identifies the source and relevant location when available and distinguishes source content from generated interpretation.
4. **Given** the AI service is unavailable or disabled, **When** the student uses core planning features, **Then** manual task, calendar, and study workflows remain available.

### US-009 — Review progress and stay motivated (Priority: P2)

As a student, I want weekly progress and understandable trends so that I can adjust goals without being judged by the app.

**Why this priority:** A review supports better planning, but it depends on enough recorded activity to be meaningful.

**Independent test:** Enter a week of tasks, study sessions, attendance, and goals; review totals and verify the stated calculation windows.

**Acceptance scenarios:**

1. **Given** the student has records in the review period, **When** they open a weekly review, **Then** completion, study time, goal progress, and attendance trends use the displayed period and definitions.
2. **Given** there is not enough history for a trend, **When** the student opens analytics, **Then** the app explains how to build a baseline rather than showing a misleading trend.
3. **Given** motivation features are disabled, **When** goals are completed, **Then** progress tracking still works without points, streak pressure, or achievement prompts.

### US-010 — Manage career and campus commitments (Priority: P2)

As a student, I want to track internships, skill goals, and campus events alongside other commitments so that career development does not disappear during the semester.

**Why this priority:** Career and campus activity adds value after core academic/personal planning is dependable.

**Independent test:** Add an application with stages and a campus event; verify reminders, status changes, and calendar visibility.

**Acceptance scenarios:**

1. **Given** an application has a role, organization, stage, and deadline, **When** the student updates its stage, **Then** the change is reflected in the tracker and any chosen reminder remains associated with that application.
2. **Given** a campus event is manually entered, **When** the student views the relevant date, **Then** the event appears with its source and time information.
3. **Given** shared study groups are not enabled, **When** the student views collaboration options, **Then** the app does not imply that tasks or notes are shared with other users.

### US-011 — Control privacy, appearance, and reliability (Priority: P1)

As a student, I want to manage data, notifications, theme, and account controls so that I can use the planner safely and reliably.

**Why this priority:** Students need clear ownership of their academic and personal data from the first release.

**Independent test:** Change theme and notification preferences, use the app offline, export data, and submit account deletion.

**Acceptance scenarios:**

1. **Given** the student has saved data and the network becomes unavailable, **When** they open and edit supported local records, **Then** the app shows the offline state and retains changes for later synchronization when sync is enabled.
2. **Given** an export is requested, **When** it completes, **Then** the student can inspect what categories were included and the export is not exposed to another account.
3. **Given** the student confirms account deletion, **When** the deletion process completes, **Then** the account is disabled/deleted and the student receives a clear result describing any retained data required by policy.
4. **Given** a screen is loading or fails, **When** the condition occurs, **Then** it provides an understandable loading, retry, or recovery state without presenting stale content as saved success.

## Functional Requirements

Priority labels: **MVP** = first viable product; **V1.1** = a later additive release; **Future** = optional advanced scope requiring further product/provider decisions. Priority does not imply implementation exists.

### A. Accounts and onboarding

- **REQ-001 [MVP]**: The product MUST provide account sign-up, login, logout, password reset, and secure session handling using a product-approved authentication method.
- **REQ-002 [MVP]**: The product MUST provide an editable student profile with timezone, university, degree, department, academic year, and active semester fields; optional fields MUST be skippable.
- **REQ-003 [MVP]**: The product MUST allow students to add, edit, archive, and select active semesters and subjects, including subject name, credits, and an optional attendance requirement.
- **REQ-004 [MVP]**: The product MUST allow students to enter or edit class meetings manually and MUST clearly show the timezone used for schedule entry and display.
- **REQ-005 [MVP]**: The product MUST collect reminder preferences, study goals, and theme preferences during or after onboarding and MUST allow changes later.
- **REQ-006 [V1.1]**: The product MUST offer timetable import from a documented supported input format, preview proposed class meetings, identify conflicts, and require student confirmation before saving.
- **REQ-007 [MVP]**: Onboarding MUST permit skipping optional steps, indicate what remains incomplete, and provide a route to finish or edit those details later.

### B. My Day dashboard

- **REQ-008 [MVP]**: My Day MUST show today's classes, appointments, due and overdue tasks, upcoming exams/assignment deadlines within a visible configurable horizon, planned study blocks, and personal habits/goals when present.
- **REQ-009 [MVP]**: My Day MUST display a daily progress indicator whose numerator and denominator have an accessible explanation and exclude items outside the selected definition.
- **REQ-010 [MVP]**: My Day MUST provide a quick-add action that creates a task with a title and allows optional date, domain, priority, and duration.
- **REQ-011 [V1.1]**: The dashboard MUST support an optional energy check-in and a supportive daily summary that identifies its data basis and can be dismissed.
- **REQ-012 [Future]**: When AI natural-language capture is enabled, the dashboard MUST show parsed fields for review and resolve ambiguity before creating or editing planner records.

### C. Academic management

- **REQ-013 [MVP]**: The product MUST support semester/subject organization, subject credits, recurring class meetings, and weekly timetable and calendar views.
- **REQ-014 [MVP]**: The product MUST support academic work items for assignments, practicals/labs, presentations, projects, and examinations, with subject, due date, status, optional estimated duration, and reminder preference.
- **REQ-015 [MVP]**: The product MUST record attendance against a dated class session using present, absent, and an institution-configurable excused/other state, and permit corrections.
- **REQ-016 [MVP]**: Attendance summaries MUST show attended sessions, eligible/held sessions, configured threshold, calculation method, and any excluded sessions.
- **REQ-017 [V1.1]**: Attendance forecasting MUST distinguish historical facts from future projections and disclose the planned-attendance assumptions used to calculate required/future classes.
- **REQ-018 [V1.1]**: The product MUST support course assessments and marks, retain their assessment labels and weights, and calculate a course summary only when the grading inputs and policy are sufficient.
- **REQ-019 [V1.1]**: GPA/CGPA outputs MUST use a selected institution/student-configured grading scale, show the courses and credits included, and label estimates as unofficial.
- **REQ-020 [V1.1]**: The product MUST allow syllabus topics/units to be represented as trackable items linked to a subject, with completion state and optional study material.
- **REQ-021 [V1.1]**: The product MUST allow a student to create an exam preparation schedule from selected topics, dates, and available study time and to edit or reject proposed sessions.
- **REQ-022 [Future]**: The product MAY provide previous-year papers and external academic resources only with clear provenance, permission/licensing review, and source links.
- **REQ-023 [MVP]**: Academic deadline reminders MUST follow per-item and global user preferences, respect granted platform permissions, and provide a visible in-app due-date fallback when notifications are unavailable.

### D. Personal planning

- **REQ-024 [MVP]**: The product MUST support personal tasks with due dates, reminders, priority, completion state, and optional recurrence independently of academic tasks.
- **REQ-025 [MVP]**: The product MUST support daily/weekly/monthly goals and recurring habits/routines, retaining occurrence-level completion history.
- **REQ-026 [V1.1]**: The product MUST provide optional trackers for reading, fitness, and self-care without presenting tracking as medical advice.
- **REQ-027 [MVP]**: The product MUST support personal events, including birthdays and appointments, with configurable reminders and optional recurrence.
- **REQ-028 [V1.1]**: The product MUST support shopping lists and errands with item-level completion and optional due dates.
- **REQ-029 [Future]**: Expense tracking MUST be opt-in, clearly separate from academic records, and provide user-controlled currency and export/delete behavior.
- **REQ-030 [MVP]**: Combined views and filters MUST distinguish academic and personal priorities and MUST not silently merge, reclassify, or delete records when filtering.

### E. Intelligent planning

- **REQ-031 [MVP]**: The product MUST provide a Deadline Radar that lists approaching and overdue academic/personal work using saved due dates and user-selected reminder/horizon settings.
- **REQ-032 [V1.1]**: Workload estimation MUST use saved task durations and schedule constraints where available, identify unknown-duration work, and state assumptions.
- **REQ-033 [V1.1]**: Prioritization recommendations MUST explain the factors used (such as due date, user priority, and estimated effort) and allow the student to change the result.
- **REQ-034 [V1.1]**: Availability detection MUST derive free periods only from entered or explicitly connected schedule data and MUST identify which sources were considered.
- **REQ-035 [V1.1]**: Energy-aware planning MUST use an optional student-provided energy preference/check-in and MUST not infer sensitive health information.
- **REQ-036 [V1.1]**: Schedule repair MUST preserve fixed classes, exams, and appointments unless the student explicitly selects them for editing; proposed moves MUST be reviewable before saving.
- **REQ-037 [V1.1]**: Semester workload forecasts MUST state their time window, input coverage, uncertainties, and the difference between forecast and recorded facts.
- **REQ-038 [V1.1]**: Rescue Mode MUST let a student select overdue/upcoming work and a recovery window, then present a feasible editable plan or explicitly state that all selected work cannot fit.
- **REQ-039 [MVP]**: Every generated schedule or priority recommendation MUST be explainable in student-facing language and MUST remain optional.

### F. Academic Memory Vault

- **REQ-040 [V1.1]**: The product MUST organize notes and document references by subject and support tags, favorites, and text search over indexed supported content.
- **REQ-041 [V1.1]**: The product MUST support user-selected file attachments subject to published file-type/size limits, available storage, and clear upload/import status.
- **REQ-042 [V1.1]**: The product MUST preview supported document types, clearly identify unsupported or failed previews, and retain the source item without claiming a preview succeeded.
- **REQ-043 [V1.1]**: The product MUST let students create and review flashcards and quizzes linked to a subject or source material.
- **REQ-044 [Future]**: AI summaries based on user materials MUST be opt-in, identify the material processed, and remain distinguishable from the original source.
- **REQ-045 [Future]**: AI-generated academic answers MUST provide source references at the available page/section/snippet level and disclose when a claim cannot be grounded in available material.

### G. AI Academic Copilot

- **REQ-046 [Future]**: The Copilot MUST convert user instructions into a proposed task with parsed date, duration, priority, domain/category, and subject when identifiable, and require confirmation before saving.
- **REQ-047 [Future]**: The Copilot MUST create proposed daily/weekly plans only from available schedule, task, and availability data, disclose constraints and assumptions, and require confirmation before persisting changes.
- **REQ-048 [Future]**: The Copilot MUST explain academic concepts in student-friendly language and identify uncertainty rather than presenting unsupported material as established fact.
- **REQ-049 [Future]**: The Copilot MUST generate summaries, revision questions, and flashcards from student-selected materials and link generated study content to those sources.
- **REQ-050 [Future]**: The Copilot MUST ask a targeted clarification question when an instruction is ambiguous in a way that would materially change saved data or a plan.
- **REQ-051 [Future]**: The Copilot MUST require explicit confirmation before creating, editing, deleting, moving, sharing, exporting, or externally submitting consequential information; it MUST show a reviewable change summary.
- **REQ-052 [Future]**: AI use MUST be user-controllable, disclose the categories of data sent to a provider, allow opt-out, and preserve manual core workflows if the service is unavailable.
- **REQ-053 [Future]**: AI provider credentials MUST NOT be embedded in the distributed client, and user materials MUST NOT be sent to an AI provider until the student has been informed and has chosen the relevant action.

### H. Progress and motivation

- **REQ-054 [V1.1]**: The product MUST support student-started study-time tracking and distinguish measured/entered time from estimated or AI-proposed time.
- **REQ-055 [V1.1]**: Completion statistics MUST disclose their period, included item types, and treatment of recurring/overdue tasks.
- **REQ-056 [V1.1]**: Attendance and academic progress views MUST derive from saved course records, identify missing data, and label non-official estimates.
- **REQ-057 [V1.1]**: The product MUST offer a weekly review of work, study sessions, habits/goals, and attendance where corresponding data exists, with meaningful empty and insufficient-history states.
- **REQ-058 [V1.1]**: The product MUST support student-defined milestones and supportive completion messages.
- **REQ-059 [Future]**: Points, achievements, streaks, and visual rewards MUST be optional, independently disableable, and must not remove access to planning or academic records when disabled.

### I. Career and campus life

- **REQ-060 [V1.1]**: The product MUST provide an internship/placement tracker with organization, opportunity, application stage, important dates, notes, and related tasks.
- **REQ-061 [V1.1]**: The product MUST allow resume, portfolio, skills, and certification milestones to be tracked as personal goals/tasks with completion evidence or links chosen by the student.
- **REQ-062 [Future]**: University events and announcements MUST show their source, update time, and relevant event timezone, and MUST be unavailable rather than fabricated when no approved source exists.
- **REQ-063 [Future]**: Study groups and shared project tasks MUST use explicit membership, sharing scope, permission, and leave/delete flows before any personal item becomes visible to another user.

### J. Settings, privacy, and reliability

- **REQ-064 [MVP]**: The product MUST provide light/dark appearance choices and a system-following option, persist the selection, and retain readable contrast and control labels.
- **REQ-065 [MVP]**: The product MUST provide global and per-category notification preferences and MUST honor denied/revoked permissions without blocking core use.
- **REQ-066 [V1.1]**: The product MUST allow the student to export a documented copy of their personal records in a usable format and identify included data categories and limitations.
- **REQ-067 [MVP]**: The product MUST provide a clear account deletion request and confirmation flow that describes consequences, identity verification, process status, and applicable retention exceptions.
- **REQ-068 [MVP]**: The product MUST provide privacy controls for optional AI, analytics, integrations, and sharing, and MUST disclose relevant data access before enabling each capability.
- **REQ-069 [MVP]**: The product MUST preserve supported core record access and edits offline, communicate sync status when sync is enabled, and make conflicting changes reviewable rather than silently discarding either edit.
- **REQ-070 [MVP]**: Each major screen MUST provide distinct loading, empty, error/retry, and offline/sync states where those states apply; stale data MUST NOT be represented as a successful save.
- **REQ-071 [MVP]**: Primary navigation and essential task, timetable, and academic interactions MUST be operable with assistive technologies and without color as the sole status cue.
- **REQ-072 [MVP]**: The product MUST adapt to supported phone sizes and text scaling without clipping essential content or making primary actions unreachable.
- **REQ-073 [MVP]**: All date-based academic and personal records MUST preserve their intended timezone/local date semantics across timezone changes and daylight-saving transitions, where applicable.
- **REQ-074 [MVP]**: The product MUST provide secure session expiration/revocation and prevent one user's authenticated records from being presented as another user's data.

## Non-Functional Requirements

- **NFR-001 — Responsiveness:** On supported devices, primary navigation and locally available records SHOULD become usable within 2 seconds after app launch under ordinary device conditions; long-running operations MUST show progress and remain cancellable where safe.
- **NFR-002 — Task interactions:** Common local actions (open a saved list, toggle completion, inspect today's schedule) SHOULD visibly respond within 500 ms on the agreed minimum supported device, excluding first-run storage migration.
- **NFR-003 — Reliability:** A user-visible save MUST either persist successfully or clearly report failure; the app MUST NOT signal success after a failed write.
- **NFR-004 — Offline behavior:** Cached/local core records MUST remain readable and supported edits MUST be retained while offline. Features requiring an external provider MUST identify their offline limitation.
- **NFR-005 — Security:** Authentication, sensitive data transport, session storage, access control, export, deletion, and third-party data flows MUST receive a threat/privacy review before release. No secret-bearing provider credential may be shipped in a client.
- **NFR-006 — Privacy:** Only data required for an enabled feature may be collected/shared. Retention, deletion completion, backups, analytics, and any legal jurisdiction requirements MUST be documented before public launch.
- **NFR-007 — Accessibility:** Target WCAG 2.2 AA for supported user-facing flows where applicable, including text contrast, scalable text, semantic labels, keyboard/switch navigation, focus visibility, and non-color status communication; verify with automated and manual checks.
- **NFR-008 — Compatibility:** MVP support is Android and iOS phones. Support for web/tablet/desktop must be explicitly tested and declared before being represented as a supported planner experience; scaffold presence alone is not support.
- **NFR-009 — Data integrity:** Academic calculations MUST be reproducible from visible inputs and policy, handle missing/inconsistent data explicitly, and retain user corrections.
- **NFR-010 — Maintainability:** Feature behavior MUST be testable independently of UI and persistence-provider choice; external integrations MUST be replaceable without making manual planner flows depend on them.
- **NFR-011 — Resilience:** Notification, identity, storage, file, and AI provider failures MUST surface understandable errors and preserve recoverable local data.
- **NFR-012 — Localization readiness:** Date, time, timezone, calendar, currency, and grade-scale presentation MUST not assume a single locale or institution when displaying student-entered data.

## Feature Prioritization Matrix

All requirements listed remain planned. Only the small checkbox prototype behavior is implemented today; no requirement below should be read as a delivered feature.

| Module | MVP | Version 1.1 | Future releases |
|---|---|---|---|
| A. Accounts/onboarding | Account lifecycle, editable profile, semester/subject setup, manual class meetings, preferences, skippable onboarding (`REQ-001–005`, `REQ-007`) | Timetable import and preview (`REQ-006`) | Add SSO/provider choice only if approved |
| B. My Day | Classes/events, deadlines, planned study, goals, progress, quick-add (`REQ-008–010`) | Energy check-in and daily summary (`REQ-011`) | AI natural-language capture (`REQ-012`) |
| C. Academic management | Semester, subjects, timetable/calendar, work items, attendance and transparent current totals, reminders (`REQ-013–016`, `REQ-023`) | Forecasts, marks, configured GPA, syllabus, exam prep (`REQ-017–021`) | Licensed/source-linked resources (`REQ-022`) |
| D. Personal planning | Personal tasks, habits/goals, events, distinct priorities (`REQ-024–025`, `REQ-027`, `REQ-030`) | Health-adjacent trackers without medical claims; shopping/errands (`REQ-026`, `REQ-028`) | Optional expenses (`REQ-029`) |
| E. Intelligent planning | Deadline Radar and transparent optional recommendations (`REQ-031`, `REQ-039`) | Workload, explainable prioritization, availability, energy-aware plans, repair, forecasts, Rescue Mode (`REQ-032–038`) | Advanced model-based planning only after validation |
| F. Memory Vault | — | Notes, tags, favorites/search, attachments/previews, manual flashcards/quizzes (`REQ-040–043`) | AI summaries and grounded answers (`REQ-044–045`) |
| G. AI Copilot | — | — | Natural-language planning, concept help, source summaries/questions, clarification and confirmation (`REQ-046–053`) |
| H. Progress | — | Study time, statistics, trends, weekly review, milestones (`REQ-054–058`) | Optional points, achievements, streaks (`REQ-059`) |
| I. Career/campus | — | Application tracking, career milestones (`REQ-060–061`) | Approved event feed and sharing/groups (`REQ-062–063`) |
| J. Settings/reliability | Theme, notifications, deletion, privacy, offline/conflict UX, accessibility, responsive phone UX, timezone/session integrity (`REQ-064–065`, `REQ-067–074`) | Export (`REQ-066`) | More providers/platforms as separately approved |

## Navigation Map

The following is the proposed information architecture. The current prototype's five bottom navigation labels do not yet lead to distinct feature screens.

```text
Unauthenticated
├── Welcome / Sign up
├── Login
└── Password reset

First-run setup (skippable where optional)
├── Profile and timezone
├── University / degree / department / academic year
├── Semester and subjects
├── Class timetable (manual; import later)
├── Goals and reminder preferences
└── Theme

Authenticated app (primary mobile navigation)
├── My Day
│   ├── Daily summary / energy check-in
│   ├── Quick add / capture
│   └── Deadline Radar
├── Academics
│   ├── Semester → subject
│   ├── Weekly timetable / calendar
│   ├── Assignments / practicals / projects / exams
│   ├── Attendance and forecasts
│   ├── Marks / credits / GPA
│   ├── Syllabus / exam preparation
│   └── Resources
├── Planner
│   ├── Day / week / month
│   ├── Academic / personal filters
│   ├── Goals / habits / routines
│   ├── Events / errands
│   └── Intelligent plan / repair / Rescue Mode
├── Vault
│   ├── Subject folders / notes / documents
│   ├── Search / tags / favorites
│   └── Flashcards / quizzes
├── My Life
│   ├── Personal tasks / routines / milestones
│   ├── Career applications / skills
│   └── Optional campus events
└── Profile and Settings (available from all primary areas)
    ├── Student / university / semester profile
    ├── Notifications / theme / privacy / AI
    ├── Export / synchronization
    ├── Account / password / delete
    └── Help / about
```

Mobile navigation may use a bottom navigation bar for a small set of high-frequency destinations and secondary navigation within each area. Desktop/web navigation must be separately adapted if those platforms are approved.

## Entity Relationship Overview

This is a conceptual domain model, not an existing database schema. All records belong to one student/account unless an explicitly authorized sharing feature is later approved.

```text
UserAccount 1 ── 1 StudentProfile
StudentProfile 1 ── * Semester
Semester 1 ── * Subject
Subject 1 ── * ClassMeeting
Subject 1 ── * AcademicWorkItem
Subject 1 ── * AttendanceSession
AttendanceSession 1 ── 0..1 AttendanceRecord (per student/session)
Subject 1 ── * Assessment
Assessment 1 ── * Mark
Subject 1 ── * SyllabusUnit
Subject 1 ── * StudyMaterial / Note
StudyMaterial 1 ── * Attachment
StudyMaterial 1 ── * Flashcard / QuizQuestion

StudentProfile 1 ── * PlannerTask
PlannerTask * ── 0..1 Subject
PlannerTask 1 ── * Reminder (optional)
StudentProfile 1 ── * PersonalEvent
StudentProfile 1 ── * Habit / Goal
Habit 1 ── * HabitOccurrence
Goal 1 ── * GoalProgressEntry
StudentProfile 1 ── * StudySession
PlannerTask 1 ── * ScheduledBlock (optional)
StudentProfile 1 ── 1 PreferenceSet
StudentProfile 1 ── * IntegrationGrant (optional)
StudentProfile 1 ── * CareerApplication (V1.1)
CareerApplication 1 ── * CareerMilestone (optional)
```

### Entity summaries

- **UserAccount / StudentProfile:** Authentication identity is distinct from editable student and academic profile fields; includes preferred timezone and lifecycle state.
- **Semester:** Academic year, term name, start/end dates, status, and optional institution/grading configuration.
- **Subject:** Semester-scoped course identity, credits, optional attendance threshold, and display metadata.
- **ClassMeeting:** Recurrence/day/time/timezone and location for a subject class. An actual dated session is separate where attendance is taken.
- **AcademicWorkItem / PlannerTask:** Due work, type/domain, subject link when academic, status, priority, estimate, and recurrence where allowed.
- **AttendanceSession / AttendanceRecord:** A held or planned class and the student's recorded status; forecast values must not be stored as actual attendance.
- **Assessment / Mark:** Assessment type, achieved/possible values, weight, date, and policy/scale reference.
- **SyllabusUnit:** Subject-linked learning unit with completion and optional source material.
- **Note / StudyMaterial / Attachment:** Subject-linked user content and file metadata; source identity and ownership are retained for generated study content.
- **Habit / HabitOccurrence / Goal / GoalProgressEntry:** Recurrence definition is separate from dated completion/progress history.
- **PersonalEvent / Reminder / PreferenceSet:** Student-owned events and per-category notification, theme, privacy, and planning choices.
- **StudySession / ScheduledBlock:** Actual recorded study is distinguished from planned or generated time blocks.
- **CareerApplication / CareerMilestone:** Optional opportunity pipeline and student-owned skills/resume milestones.
- **IntegrationGrant:** Provider, scope, consent time, status, and revocation state; never treat a connection as blanket permission to share all records.

## External Services and Integrations

No external service is configured in the current repository. These are candidates, not selected vendors or claims of existing integration.

| Service category | Purpose | Release | Data/permission considerations |
|---|---|---|---|
| Authentication and account backend | Sign-up/login, password recovery, session revocation, account deletion | MVP if account-required policy is confirmed | Credentials/session handling, account recovery, deletion lifecycle, access isolation |
| Local persistence | Offline storage for planner, academic, and personal records | MVP | Protect sensitive local data as appropriate; define backup/migration/export behavior |
| Remote sync API/storage | Cross-device sync and cloud recovery | Conditional MVP/V1.1 only if promised | Conflict resolution, encryption, retention, data residency, deletion from backups |
| Local notification capability | Device reminders when the app is not open | MVP | Explicit permission, quiet hours, opt-out, platform behavior |
| AI model/provider service | Natural-language parsing, explanations, summaries, study questions | Future | Explicit consent, data minimization, provider retention/training policy, citations, server-held credentials |
| University/LMS provider | Import courses, schedules, assignments, grades, or events | Future and institution-specific | Student authorization, scopes, terms, official-data provenance, token revocation |
| Calendar provider | Optional import/export/synchronization of classes, events, and study blocks | Future | Read/write scope separately granted; duplicate and conflict policy; timezone handling |
| File/object storage | Sync attachments and backup materials across devices | V1.1 if cloud attachments are approved | File limits, access controls, malware/content validation, retention, user deletion |
| Analytics/crash diagnostics | Reliability/product measurement | Optional; only after privacy decision | Minimize or aggregate personal/academic content; opt-out where applicable; retention disclosure |
| Campus announcements/events feed | Display institution events and notices | Future | Approved source, update freshness, attribution, permission and source failure behavior |

External providers MUST be replaceable behind product-level capabilities. Core manual planning MUST NOT require an LMS, calendar, AI, or campus feed integration.

## Risk Register

Ratings are qualitative and provisional, based on product scope rather than a completed security/legal assessment.

| Risk | Likelihood / impact | Mitigation and acceptance evidence |
|---|---|---|
| Sensitive academic/personal records are exposed through account, sync, or device loss | Medium / High | Data-flow and threat review; per-account authorization tests; secure session lifecycle; local protection and deletion/export verification before launch |
| Product assumes an incorrect grading or attendance policy | High / High | Make scales/thresholds configurable; show formulas and inputs; label unofficial results; test boundary cases with student-reviewed examples |
| Timezone, recurring class, or daylight-saving changes move deadlines/classes unexpectedly | Medium / High | Store intended timezone/local date semantics; test DST and timezone changes; never silently rewrite historical attendance or completed events |
| Sync conflict overwrites a student's offline edit | Medium / High | Queue offline edits, surface conflict resolution, test simultaneous edits and retry/idempotency paths |
| AI hallucinates a deadline, academic answer, or plan | High / High | Confirmation gate; source citations; uncertainty disclosure; no automatic consequential changes; retain manual workflows |
| User materials are sent to an AI provider without informed consent | Medium / High | Per-action opt-in and data preview; minimize transmitted content; provider and retention disclosure; revocation and auditability |
| External LMS or calendar API is unavailable, restricted, or institution-specific | High / Medium | Treat integrations as optional; provider feasibility checks; graceful disconnection; manual entry remains complete |
| Notification denial, delivery restrictions, or over-notification erodes trust | Medium / Medium | Permission-aware UX; per-category controls; quiet-hour settings; in-app deadline fallback; measure opt-outs |
| Uploaded file is unsupported, too large, malicious, or unavailable offline | Medium / High | Publish limits, validate type/size, handle scanning where remote upload is provided, safe preview failure, clear local/cloud ownership |
| MVP scope grows to include all ten domains and cannot be validated | High / High | Enforce release matrix; ship coherent task/academic/day-planning slice; require explicit phase exit evidence |
| Accessibility or small screens make planning tasks unreachable | Medium / High | Accessibility criteria and manual assistive-tech testing; scalable text, focus/semantics, layout tests at agreed widths |
| Gamification or reminders create shame or unhealthy pressure | Medium / Medium | Make optional and disableable; supportive copy; avoid punitive streak loss and guilt-driven alerts; review with students |
| Financial or career data receives weaker protection than academic data | Low / High | Keep optional expense/career data out of MVP; separate controls and exports; privacy review before release |
| Account deletion leaves data in backups or third-party systems without disclosure | Medium / High | Document deletion propagation/retention limits and status; verify provider deletion and backup expiry policy before offering cloud sync |
| Starter release identity/signing configuration is accidentally shipped | Medium / High | Release gate for real app identity, production signing, icons, and configuration; block debug signing for distribution builds |

## Definition of Done by Major Feature

The following gates apply to the feature's assigned release. Later features do not inherit a claim of completion simply because a related data field exists.

| Feature area | Definition of done |
|---|---|
| Accounts and onboarding | Sign-up/login/logout/reset and session lifecycle pass success, validation, recovery, and security tests; profile/semester setup persists; optional steps can be skipped and revisited; account isolation is verified. |
| My Day dashboard | Today, overdue, upcoming, study, personal, and empty states are tested against time-boundary fixtures; progress definition is visible; quick-add persists; accessibility navigation works. |
| Academics | Semester/subject/class/work-item create/edit/archive flows persist; weekly schedule handles timezone/recurrence; attendance and marks show reproducible calculation inputs; correction paths are tested. |
| Personal planning | Task, reminder, event, habit, routine, and goal recurrence/completion history behave correctly across dates; academic/personal separation is visible and filter-safe. |
| Intelligent planning | Recommendations disclose input and rationale; unavailable-time/insufficient-data conditions are handled; fixed events remain fixed; all proposed modifications require review; repair scenarios are tested. |
| Academic Memory Vault | Subjects/tags/favorites/search return correct results; attachments obey limits and ownership; preview failures are explicit; generated study items retain links to source material. |
| AI Academic Copilot | Consent precedes relevant data transfer; ambiguous and adversarial/untrusted source cases are tested; outputs distinguish fact from generation; citations are verifiable; confirmation, opt-out, and provider failure paths work. |
| Progress and motivation | Metrics state the period and calculation; missing history is not fabricated; study time differentiates actual/estimated; optional reward features can be disabled without losing core records. |
| Career and campus | Application/milestone state and reminders persist; event provenance is visible; integrations fail gracefully; future sharing has permission and leave/delete coverage before release. |
| Settings and reliability | Theme, notification, privacy, offline, retry, export, and deletion flows have tests; supported core offline changes survive restart and sync conflict; accessibility, supported screen sizes, release identity, and recovery are verified. |

## Assumptions and Open Decisions

1. “Student” refers to an individual university student managing their own information; instructor, administrator, and family accounts are out of scope.
2. Core tasks, schedules, and student-entered academic/personal records should work offline. Remote sync is conditional on the product choosing to promise multi-device backup.
3. University policies vary. Attendance thresholds, grading scales, credit rules, and term labels are configured per student/institution rather than hard-coded globally.
4. MVP targets Android and iOS phones. The existing repository contains additional platform scaffolding, but scaffold presence alone does not make web/desktop a supported MVP.
5. Account requirement, data residency/legal jurisdiction, and final product name remain open decisions in the scope baseline and must be resolved before implementation planning locks account and hosting boundaries.
6. Timetable import, LMS access, calendar sync, AI, and campus feeds depend on provider availability/terms and are not assumed to exist.
7. Expense tracking, gamification, and study-group collaboration are opt-in or later-release features.
8. Numeric performance and accessibility targets in this document are proposed acceptance targets and should be validated against agreed minimum devices and applicable policy before launch.

## Success Criteria

Targets below are proposed and should be confirmed with student research and the MVP device/support matrix.

- **SC-001:** At least 90% of first-time test participants can complete account setup, add a semester/subject, and reach My Day without assistance in five minutes or less.
- **SC-002:** At least 90% of tested students can create, edit, complete, and find a task through the intended core flows without data loss.
- **SC-003:** For records available locally, 95% of dashboard list-opening and completion interactions provide visible feedback within 500 ms on the agreed minimum supported phone.
- **SC-004:** All tested due-date, recurring-class, and reminder cases spanning timezone changes and daylight-saving boundaries display the expected local date and time.
- **SC-005:** 100% of evaluated attendance/GPA summaries expose the configured scale/threshold, included inputs, and result status (recorded versus forecast/unofficial).
- **SC-006:** In usability testing, at least 85% of participants can identify today's next academic deadline and distinguish personal from academic commitments within 30 seconds.
- **SC-007:** All critical MVP flows can be completed using screen-reader semantics and text scaling at the agreed accessibility test matrix without a color-only status dependency.
- **SC-008:** Offline tests retain 100% of acknowledged local edits across app restart; synchronization conflict tests never silently discard either conflicting student edit.
- **SC-009:** Every AI-generated study answer in supported evaluation scenarios provides a verifiable source reference or explicitly reports that no supporting source was found.
- **SC-010:** At least 80% of beta participants report that weekly review and reminders help them plan, with no increase in self-reported guilt/pressure compared with their baseline.
- **SC-011:** Every release-critical save/export/delete scenario reports success only after the operation reaches its documented completion state; failure and retry outcomes are tested.

## Implementation Status Snapshot

| Capability | Status observed in repository |
|---|---|
| Flutter/Dart app launch | Present; `lib/main.dart` runs `MyPlannerApp`. |
| Sample daily task list and completion toggle | Present, hard-coded and in-memory only. |
| Progress display and five navigation labels | Present; the labels do not navigate to separate feature screens. |
| Persistent tasks, accounts, academic data, timetable, reminders, integrations, AI, or analytics | Not found. |
| Test health | Existing widget test is stale and fails to compile because it expects `MyApp`; analyzer reports the same undefined class. |
| Runtime UI issue | Connected app reported the `ListTile` background/ink visibility assertion for task tiles. |
| Product readiness | Prototype only; the features in this specification are planned, not implemented or verified. |
