import assert from "node:assert/strict";
import { after, before, test } from "node:test";
import {
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  deleteUser,
  getAuth,
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
  signOut,
} from "firebase/auth";
import { initializeApp, deleteApp } from "firebase/app";

const projectId = "demo-student-planner";
const app = initializeApp(
  {
    apiKey: "demo-api-key",
    authDomain: "localhost",
    projectId,
    appId: "demo-app-id",
  },
  `auth-emulator-test-${Date.now()}`,
);
const auth = getAuth(app);
let createdUser;

before(() => {
  connectAuthEmulator(auth, "http://127.0.0.1:9099", {
    disableWarnings: true,
  });
});

after(async () => {
  if (createdUser) {
    await signInWithEmailAndPassword(auth, createdUser.email, "StudentPass123!");
    await deleteUser(auth.currentUser);
  }
  await deleteApp(app);
});

test("registration, login, password reset, and logout work with the Auth emulator", async () => {
  const email = `student-${Date.now()}@example.com`;
  const password = "StudentPass123!";
  const credential = await createUserWithEmailAndPassword(auth, email, password);
  createdUser = { email };
  const uid = credential.user.uid;
  assert.equal(auth.currentUser.uid, uid);
  await signOut(auth);
  assert.equal(auth.currentUser, null);

  await signInWithEmailAndPassword(auth, email, password);
  assert.equal(auth.currentUser.uid, uid);

  await sendPasswordResetEmail(auth, email);
  await signOut(auth);
  assert.equal(auth.currentUser, null);
});
