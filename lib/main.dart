import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'app/planner_app.dart';
import 'data/account_service.dart';
import 'data/firebase_config.dart';
import 'data/planner_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AccountService? accountService;
  FirebaseTaskPersistence? taskPersistence;
  if (FirebaseRuntimeConfig.isConfigured) {
    await Firebase.initializeApp(options: FirebaseRuntimeConfig.options);
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    if (FirebaseRuntimeConfig.useEmulators) {
      auth.useAuthEmulator(FirebaseRuntimeConfig.emulatorHost, 9099);
      firestore.useFirestoreEmulator(FirebaseRuntimeConfig.emulatorHost, 8080);
      storage.useStorageEmulator(FirebaseRuntimeConfig.emulatorHost, 9199);
    }
    accountService = FirebaseAccountService(
      auth: auth,
      firestore: firestore,
      storage: storage,
    );
    taskPersistence = FirebaseTaskPersistence(auth: auth, firestore: firestore);
  }
  runApp(
    MyPlannerApp(
      accountService: accountService,
      taskPersistence: taskPersistence,
    ),
  );
}
