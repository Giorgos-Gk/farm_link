import 'package:cloud_firestore/cloud_firestore.dart';

class FarmLinkUser {
  final String documentId;
  final String email;
  final String username;
  final String photoUrl;

  FarmLinkUser({
    required this.documentId,
    required this.email,
    required this.username,
    required this.photoUrl,
  });

  factory FarmLinkUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document does not exist or data is null');
    }
    return FarmLinkUser(
      documentId: doc.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'FarmLinkUser(documentId: $documentId, email: $email, username: $username, photoUrl: $photoUrl)';
  }
}
