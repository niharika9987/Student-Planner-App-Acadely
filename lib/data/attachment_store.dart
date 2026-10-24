import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseAttachmentStore {
  FirebaseAttachmentStore({required this._auth, required this._storage});

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  Future<String> upload({
    required String fileName,
    required String contentType,
    required Uint8List bytes,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Sign in to upload an attachment.');
    if (fileName.trim().isEmpty ||
        fileName.contains('/') ||
        fileName.contains('\\') ||
        bytes.isEmpty ||
        bytes.length > 20 * 1024 * 1024 ||
        !_allowedContentTypes.contains(contentType)) {
      throw ArgumentError('Attachment type, name, or size is invalid.');
    }
    final reference = _storage.ref(
      'users/$uid/attachments/${DateTime.now().microsecondsSinceEpoch}_$fileName',
    );
    await reference.putData(bytes, SettableMetadata(contentType: contentType));
    return reference.fullPath;
  }

  static const _allowedContentTypes = {
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'image/jpeg',
    'image/png',
    'text/plain',
  };
}
