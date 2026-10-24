import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { after, before, test } from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, updateDoc } from "firebase/firestore";

let testEnvironment;
const timestamp = new Date("2026-01-01T00:00:00.000Z");

before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId: "demo-student-planner",
    firestore: {
      rules: await readFile(new URL("../firestore.rules", import.meta.url), "utf8"),
    },
  });
});

after(async () => {
  await testEnvironment?.cleanup();
});

function task(ownerUid, title = "Review lecture notes") {
  return {
    ownerUid,
    type: "tasks",
    data: {
      title,
      category: "academic",
      dueLabel: "Today",
      priority: "high",
      isCompleted: false,
      isAssignment: false,
    },
    createdAt: timestamp,
    updatedAt: timestamp,
  };
}

function profile(email) {
  return {
    displayName: "Student",
    email,
    university: null,
    universityId: null,
    degree: null,
    department: null,
    currentSemester: null,
    academicYear: null,
    timezone: "UTC",
    preferredWeekStart: 1,
    theme: "system",
    notificationsEnabled: true,
    studyGoals: [],
    onboardingComplete: true,
    schemaVersion: 1,
    createdAt: timestamp,
    updatedAt: timestamp,
  };
}

test("a student can read and write only their own profile and task records", async () => {
  const alice = testEnvironment.authenticatedContext("alice", {
    email: "alice@example.com",
  }).firestore();
  const bob = testEnvironment.authenticatedContext("bob", {
    email: "bob@example.com",
  }).firestore();
  const aliceProfile = doc(alice, "users/alice");
  const aliceTask = doc(alice, "users/alice/tasks/task-1");

  await assertSucceeds(setDoc(aliceProfile, profile("alice@example.com")));
  await assertSucceeds(setDoc(aliceTask, task("alice")));
  await assertSucceeds(getDoc(aliceProfile));
  await assertSucceeds(getDoc(aliceTask));
  await assertSucceeds(setDoc(doc(bob, "users/bob/tasks/task-2"), task("bob")));
  await assertFails(getDoc(doc(alice, "users/bob/tasks/task-2")));
  await assertFails(
    updateDoc(doc(alice, "users/bob/tasks/task-2"), {
      "data.title": "Changed by Alice",
    }),
  );
  await assertFails(getDoc(doc(bob, "users/alice")));
  await assertFails(getDoc(doc(bob, "users/alice/tasks/task-1")));
  await assertFails(
    updateDoc(doc(bob, "users/alice"), { displayName: "Changed by Bob" }),
  );
  await assertFails(updateDoc(doc(bob, "users/alice/tasks/task-1"), {
    "data.title": "Changed by Bob",
  }));
});

test("unauthenticated clients cannot access user records", async () => {
  const guest = testEnvironment.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(guest, "users/alice")));
  await assertFails(setDoc(doc(guest, "users/alice/tasks/task-1"), task("alice")));
});

test("server rules reject forged ownership and invalid task fields", async () => {
  const alice = testEnvironment.authenticatedContext("alice", {
    email: "alice@example.com",
  }).firestore();
  await assertFails(
    setDoc(doc(alice, "users/alice/tasks/forged-owner"), task("bob")),
  );
  await assertFails(
    setDoc(
      doc(alice, "users/alice/tasks/invalid-priority"),
      {
        ...task("alice"),
        data: { ...task("alice").data, priority: "urgent" },
      },
    ),
  );
  await assertFails(
    setDoc(doc(alice, "users/alice"), {
      ...profile("someone-else@example.com"),
      displayName: "X".repeat(101),
    }),
  );
});
