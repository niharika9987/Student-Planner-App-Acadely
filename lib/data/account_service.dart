import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'planner_record.dart';
import 'student_profile.dart';

class AccountFailure implements Exception {
  const AccountFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AccountIdentity {
  const AccountIdentity({required this.uid, required this.email});

  final String uid;
  final String email;
}

abstract interface class AccountService {
  Stream<AccountIdentity?> authStateChanges();

  AccountIdentity? get currentIdentity;

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> sendPasswordReset(String email);

  Future<StudentProfile?> loadProfile(String uid);

  Future<void> saveProfile(String uid, StudentProfile profile);

  Future<void> signOut();

  Future<void> deleteAccount({required String password});
}

class FirebaseAccountService implements AccountService {
  FirebaseAccountService({
    required this._auth,
    required this._firestore,
    required this._storage,
  });

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Stream<AccountIdentity?> authStateChanges() => _auth.authStateChanges().map(
    (user) => user == null
        ? null
        : AccountIdentity(uid: user.uid, email: user.email ?? ''),
  );

  @override
  AccountIdentity? get currentIdentity {
    final user = _auth.currentUser;
    return user == null
        ? null
        : AccountIdentity(uid: user.uid, email: user.email ?? '');
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AccountFailure('Account creation could not be completed.');
      }
      await user.updateDisplayName(displayName.trim());
      await _profileRef(user.uid).set({
        ...StudentProfile(
          displayName: displayName.trim(),
          email: user.email ?? email.trim(),
        ).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(_authErrorMessage(error.code));
    } on FirebaseException catch (_) {
      throw const AccountFailure(
        'Your account was created, but the profile could not be saved. Sign in and try again.',
      );
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(_authErrorMessage(error.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(_authErrorMessage(error.code));
    }
  }

  @override
  Future<StudentProfile?> loadProfile(String uid) async {
    _requireOwner(uid);
    try {
      final snapshot = await _profileRef(uid).get();
      if (!snapshot.exists) return null;
      return StudentProfile.fromMap(snapshot.data()!);
    } on FirebaseException catch (_) {
      throw const AccountFailure('Could not load your profile. Try again.');
    }
  }

  @override
  Future<void> saveProfile(String uid, StudentProfile profile) async {
    _requireOwner(uid);
    _validateProfile(profile);
    try {
      final profileRef = _profileRef(uid);
      final existing = await profileRef.get();
      await profileRef.set({
        ...profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt':
            existing.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (_) {
      throw const AccountFailure('Could not save your profile. Try again.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(_authErrorMessage(error.code));
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AccountFailure('Sign in again before deleting your account.');
    }
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
      for (final collection in PlannerCollection.values) {
        final collectionRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection(collection.path);
        while (true) {
          final page = await collectionRef.limit(400).get();
          if (page.docs.isEmpty) break;
          final batch = _firestore.batch();
          for (final document in page.docs) {
            batch.delete(document.reference);
          }
          await batch.commit();
        }
      }
      await _deleteStorageTree(_storage.ref('users/${user.uid}/attachments'));
      await _profileRef(user.uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(_authErrorMessage(error.code));
    } on FirebaseException catch (_) {
      throw const AccountFailure(
        'Account data could not be fully deleted. Contact support before trying again.',
      );
    }
  }

  DocumentReference<Map<String, dynamic>> _profileRef(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<void> _deleteStorageTree(Reference directory) async {
    final result = await directory.listAll();
    for (final file in result.items) {
      await file.delete();
    }
    for (final folder in result.prefixes) {
      await _deleteStorageTree(folder);
    }
  }

  void _requireOwner(String uid) {
    if (_auth.currentUser?.uid != uid) {
      throw const AccountFailure(
        'You are not authorized to access this profile.',
      );
    }
  }

  void _validateProfile(StudentProfile profile) {
    if (profile.displayName.trim().isEmpty ||
        profile.displayName.trim().length > 100) {
      throw const AccountFailure('Enter a name between 1 and 100 characters.');
    }
    if ((profile.university?.length ?? 0) > 160 ||
        (profile.degree?.length ?? 0) > 120 ||
        (profile.department?.length ?? 0) > 120 ||
        (profile.currentSemester?.length ?? 0) > 120 ||
        (profile.academicYear?.length ?? 0) > 40 ||
        profile.timezone.length > 100) {
      throw const AccountFailure('One or more profile fields are too long.');
    }
    if (profile.preferredWeekStart < 1 || profile.preferredWeekStart > 7) {
      throw const AccountFailure('Choose a valid first day of the week.');
    }
    if (!{'light', 'dark', 'system'}.contains(profile.theme)) {
      throw const AccountFailure('Choose a valid theme preference.');
    }
    if (profile.studyGoals.length > 20 ||
        profile.studyGoals.any((goal) => goal.trim().length > 120)) {
      throw const AccountFailure(
        'Study goals must be 120 characters or fewer.',
      );
    }
  }

  String _authErrorMessage(String code) => switch (code) {
    'invalid-email' => 'Enter a valid email address.',
    'email-already-in-use' =>
      'An account could not be created with these details.',
    'weak-password' => 'Choose a stronger password.',
    'user-disabled' => 'This account is unavailable. Contact support.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Email or password is incorrect.',
    'too-many-requests' => 'Too many attempts. Wait a while and try again.',
    'network-request-failed' => 'Check your connection and try again.',
    'requires-recent-login' => 'Sign in again, then retry this action.',
    _ => 'The account request could not be completed. Please try again.',
  };
}
