import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financy_control/core/data/data_result.dart';
import 'package:financy_control/core/data/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../profile_image_service.dart';

class Base64ProfileImageService implements ProfileImageService {
  Base64ProfileImageService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  @override
  Future<DataResult<String>> saveAvatar(XFile file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return DataResult.failure(const UnknownFailure('No authenticated user'));
      }

      // Read original bytes
      final originalBytes = await file.readAsBytes();

      // Compress & resize to ~128x128 max preserving aspect ratio
      final compressedBytes = await _compressImage(originalBytes, maxWidth: 128, maxHeight: 128);

      final b64 = base64Encode(compressedBytes);

      // Guard against oversize (Firestore doc limit 1MiB, keep avatar < 200KB base64)
      if (b64.length > 200000) {
        return DataResult.failure(const UnknownFailure('Avatar too large after compression'));
      }

      await _users.doc(user.uid).update({'avatarBase64': b64});
      return DataResult.success(b64);
    } catch (e) {
      return DataResult.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<DataResult<String>> loadAvatar() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return DataResult.failure(const UnknownFailure('No authenticated user'));
      }
      final doc = await _users.doc(user.uid).get();
      final data = doc.data();
      if (data == null || data['avatarBase64'] == null) {
        return DataResult.failure(const UnknownFailure('No avatar stored'));
      }
      return DataResult.success(data['avatarBase64'] as String);
    } catch (e) {
      return DataResult.failure(UnknownFailure(e.toString()));
    }
  }

  Future<Uint8List> _compressImage(
    Uint8List bytes, {
    required int maxWidth,
    required int maxHeight,
  }) async {
    // Use flutter_image_compress for resizing & jpeg re-encoding
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      format: CompressFormat.jpeg,
      quality: 70, // balance size/clarity
      minWidth: maxWidth,
      minHeight: maxHeight,
    );
    return Uint8List.fromList(result);
  }
}
