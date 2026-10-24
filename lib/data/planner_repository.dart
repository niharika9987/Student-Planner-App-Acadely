import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'planner_record.dart';
import 'planner_store.dart';

class PlannerDataFailure implements Exception {
  const PlannerDataFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirebasePlannerRepository {
  FirebasePlannerRepository({required this._auth, required this._firestore});

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<List<PlannerRecord>> watchRecords(PlannerCollection collection) {
    final uid = _requireUser();
    return _userCollection(uid, collection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => _fromSnapshot(collection, document))
              .toList(growable: false),
        );
  }

  Future<PlannerRecord?> getRecord(
    PlannerCollection collection,
    String id,
  ) async {
    final uid = _requireUser();
    try {
      final snapshot = await _userCollection(uid, collection).doc(id).get();
      return snapshot.exists ? _fromSnapshot(collection, snapshot) : null;
    } on FirebaseException catch (_) {
      throw const PlannerDataFailure('Could not load this item. Try again.');
    }
  }

  Future<String> createRecord(
    PlannerCollection collection,
    Map<String, dynamic> data,
  ) async {
    final uid = _requireUser();
    _requireWritableSchema(collection);
    _validateData(data);
    try {
      final document = _userCollection(uid, collection).doc();
      await document.set({
        'ownerUid': uid,
        'type': collection.path,
        'data': data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return document.id;
    } on FirebaseException catch (_) {
      throw const PlannerDataFailure('Could not save this item. Try again.');
    }
  }

  Future<void> updateRecord(
    PlannerCollection collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final uid = _requireUser();
    _requireWritableSchema(collection);
    _validateData(data);
    try {
      await _userCollection(uid, collection).doc(id).update({
        'data': data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (_) {
      throw const PlannerDataFailure('Could not update this item. Try again.');
    }
  }

  Future<void> deleteRecord(PlannerCollection collection, String id) async {
    final uid = _requireUser();
    try {
      await _userCollection(uid, collection).doc(id).delete();
    } on FirebaseException catch (_) {
      throw const PlannerDataFailure('Could not delete this item. Try again.');
    }
  }

  CollectionReference<Map<String, dynamic>> _userCollection(
    String uid,
    PlannerCollection collection,
  ) => _firestore.collection('users').doc(uid).collection(collection.path);

  String _requireUser() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const PlannerDataFailure('Sign in to access planner data.');
    }
    return uid;
  }

  void _validateData(Map<String, dynamic> data) {
    if (data.isEmpty || data.length > 32) {
      throw const PlannerDataFailure('This item has an invalid data shape.');
    }
    if (data.keys.any((key) => key == 'ownerUid' || key == 'type')) {
      throw const PlannerDataFailure('Ownership fields cannot be changed.');
    }
    for (final entry in data.entries) {
      if (entry.key.isEmpty ||
          entry.key.length > 64 ||
          entry.value is String && (entry.value as String).length > 5000) {
        throw const PlannerDataFailure('One or more fields are invalid.');
      }
    }
  }

  void _requireWritableSchema(PlannerCollection collection) {
    if (collection != PlannerCollection.tasks) {
      throw const PlannerDataFailure(
        'Writes for this record type are not enabled until its server validation schema is defined.',
      );
    }
  }

  PlannerRecord _fromSnapshot(
    PlannerCollection collection,
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final map = snapshot.data();
    if (map == null ||
        map['type'] != collection.path ||
        map['ownerUid'] != _auth.currentUser?.uid ||
        map['data'] is! Map<String, dynamic>) {
      throw const PlannerDataFailure('This item could not be verified.');
    }
    return PlannerRecord(
      id: snapshot.id,
      ownerUid: map['ownerUid'] as String,
      collection: collection,
      data: Map<String, dynamic>.from(map['data'] as Map<String, dynamic>),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class FirebaseTaskPersistence implements TaskPersistence {
  FirebaseTaskPersistence({required this._auth, required this._firestore});

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasks {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const PlannerPersistenceFailure('Sign in to load your tasks.');
    }
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  @override
  Future<List<PlannerTask>> loadTasks() async {
    try {
      final snapshot = await _tasks
          .orderBy('updatedAt', descending: true)
          .get();
      return snapshot.docs.map(_fromSnapshot).toList(growable: true);
    } on FirebaseException catch (_) {
      throw const PlannerPersistenceFailure(
        'Could not load your tasks. Try again.',
      );
    }
  }

  @override
  Future<void> saveTask(PlannerTask task) async {
    try {
      final reference = _tasks.doc(task.id);
      final existing = await reference.get();
      final uid = _auth.currentUser!.uid;
      final payload = {
        'ownerUid': uid,
        'type': PlannerCollection.tasks.path,
        'data': {
          'title': task.title.trim(),
          'category': task.category.name,
          'dueLabel': task.dueLabel,
          'priority': task.priority.name,
          'isCompleted': task.isCompleted,
          'isAssignment': task.isAssignment,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (existing.exists) {
        await reference.update(payload);
      } else {
        await reference.set({
          ...payload,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (_) {
      throw const PlannerPersistenceFailure(
        'Could not save your task. Try again.',
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _tasks.doc(id).delete();
    } on FirebaseException catch (_) {
      throw const PlannerPersistenceFailure(
        'Could not delete your task. Try again.',
      );
    }
  }

  PlannerTask _fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final record = snapshot.data();
    final data = record['data'];
    if (record['ownerUid'] != _auth.currentUser?.uid ||
        record['type'] != PlannerCollection.tasks.path ||
        data is! Map<String, dynamic> ||
        data['title'] is! String ||
        data['category'] is! String ||
        data['priority'] is! String ||
        data['dueLabel'] is! String ||
        data['isCompleted'] is! bool ||
        data['isAssignment'] is! bool) {
      throw const PlannerPersistenceFailure(
        'A saved task could not be verified.',
      );
    }
    return PlannerTask(
      id: snapshot.id,
      title: data['title'] as String,
      category: switch (data['category']) {
        'personal' => TaskCategory.personal,
        'academic' => TaskCategory.academic,
        _ => throw const PlannerPersistenceFailure(
          'A saved task has an invalid category.',
        ),
      },
      dueLabel: data['dueLabel'] as String,
      priority: switch (data['priority']) {
        'low' => TaskPriority.low,
        'normal' => TaskPriority.normal,
        'high' => TaskPriority.high,
        _ => throw const PlannerPersistenceFailure(
          'A saved task has an invalid priority.',
        ),
      },
      isCompleted: data['isCompleted'] as bool,
      isAssignment: data['isAssignment'] as bool,
    );
  }
}
