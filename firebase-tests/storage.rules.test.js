import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { after, before, test } from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";

let testEnvironment;

before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId: "demo-student-planner",
    storage: {
      rules: await readFile(new URL("../storage.rules", import.meta.url), "utf8"),
    },
  });
});

after(async () => {
  await testEnvironment?.cleanup();
});

test("attachments are private to their owner and restrict type and size", async () => {
  const alice = testEnvironment.authenticatedContext("alice").storage();
  const bob = testEnvironment.authenticatedContext("bob").storage();
  const path = "users/alice/attachments/notes.pdf";
  const upload = alice.ref(path).put(new Uint8Array([1, 2, 3]), {
    contentType: "application/pdf",
  });

  await assertSucceeds(upload);
  await assertFails(bob.ref(path).getMetadata());
  await assertFails(
    alice.ref("users/alice/attachments/script.txt").put(
      new Uint8Array([1]),
      { contentType: "text/html" },
    ),
  );
  await assertFails(
    alice.ref("users/alice/attachments/too-large.pdf").put(
      new Uint8Array(20 * 1024 * 1024 + 1),
      { contentType: "application/pdf" },
    ),
  );
});

test("unauthenticated clients cannot upload attachments", async () => {
  const guest = testEnvironment.unauthenticatedContext().storage();
  await assertFails(
    guest.ref("users/alice/attachments/notes.pdf").put(
      new Uint8Array([1]),
      { contentType: "application/pdf" },
    ),
  );
});
