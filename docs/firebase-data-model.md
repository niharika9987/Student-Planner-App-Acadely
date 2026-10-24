# Firebase data model

The app uses Firebase Authentication for email/password credentials and Cloud Firestore for profiles and planner records. Every private document is under `users/{uid}`. The UID comes from Firebase Authentication, never from a caller-provided profile field. Firestore Rules enforce owner-only reads and writes, while Storage Rules limit file paths to the same UID.

## Profile

`users/{uid}` contains:

| Field | Type | Notes |
|---|---|---|
| `displayName`, `email` | string | Name is 1–100 characters; email must match the authenticated token. |
| `university`, `universityId`, `degree`, `department`, `currentSemester`, `academicYear` | string or null | Optional profile details; a catalogue match can use `universityId`. |
| `timezone` | string | IANA timezone identifier preferred by the client. |
| `preferredWeekStart` | integer | ISO weekday, 1 (Monday) through 7 (Sunday). |
| `theme` | string | `light`, `dark`, or `system`. |
| `notificationsEnabled` | boolean | User-level notification preference. |
| `studyGoals` | string array | Up to 20 short goal labels. |
| `onboardingComplete` | boolean | Controls whether the protected planner shell can be shown. |
| `schemaVersion` | integer | Profile schema version; currently 1. |
| `createdAt`, `updatedAt` | Firestore timestamp | Set by server timestamp transforms. |

## User-owned record envelope

Each private collection document has a Firestore-generated or stable document ID and this envelope:

```text
users/{uid}/{collection}/{recordId}
  ownerUid: uid
  type: collection name
  data: collection-specific payload map
  createdAt: server timestamp
  updatedAt: server timestamp
```

`ownerUid` and `type` are immutable after creation. The current model catalog includes:

| Collection | Key payload relationships and fields |
|---|---|
| `academicTerms` | name, academic year, start/end dates, university ID |
| `subjects` | name/code, credits, department, syllabus reference |
| `subjectEnrollments` | academic-term ID, subject ID, enrollment status |
| `classSessions`, `timetableEntries` | subject ID, weekday/date, start/end, room |
| `attendanceRecords` | subject ID, class-session ID, date, attendance status |
| `assignments` | subject ID, task ID, title, due date, status |
| `assignmentMilestones` | assignment ID, title, due date, completion |
| `exams`, `assessmentComponents`, `grades` | subject/term IDs, assessment kind, score, maximum, credits |
| `tasks`, `subtasks` | title, category, priority, due label, completion, parent task ID |
| `personalEvents` | title, start/end, location, reminder preference |
| `habits`, `habitCompletions` | habit ID, schedule, completion date/value |
| `goals`, `goalMilestones` | goal ID, target date, milestone status |
| `studySessions` | subject/task IDs, start/end, duration, notes |
| `notes` | title/body, subject/term IDs, tags, favorite state |
| `attachments` | note/subject IDs, storage path, content type, byte size |
| `flashcards`, `quizzes` | subject/note IDs, prompts, answers, source reference |
| `notifications` | record ID, scheduled time, delivery/read state |
| `userPreferences` | preference key/value and update timestamp |
| `aiPlanningSuggestions` | generated suggestion, source record IDs, explanation, accepted state |
| `auditRecords` | server-managed immutable audit metadata; clients cannot create/update |

`universities/{universityId}` is a shared, read-only catalogue with `name`, `countryCode`, and optional aliases. The profile stores both the selected ID and display name; user-entered university names remain valid when a catalogue match is unavailable. No client write is permitted to the catalogue.

Firestore does not provide SQL foreign keys or transactional relational constraints. Relationship IDs are stored in record payloads; feature repositories must validate referenced record ownership and existence when those workflows are implemented. Firestore Rules currently enforce the profile schema, task payload shape, record envelope, owner scope, size limits, and immutable ownership/type fields. Extend per-collection rules before enabling writes for additional record types.

Firestore single-field indexes cover the current owner-scoped `updatedAt` task/record ordering. No composite index is currently required. Update `firestore.indexes.json` when a query adds multiple filter/order fields.

## Attachments and deletion

Files are uploaded to private Firebase Storage paths under `users/{uid}/attachments/`; Firestore stores only the Storage path and metadata, not public URLs. Storage Rules enforce ownership, allowed MIME types, and a 20 MiB maximum. Account deletion requires a recent password reauthentication, removes records from every `PlannerCollection`, removes the private attachment tree and profile, then deletes the Firebase Authentication user.
