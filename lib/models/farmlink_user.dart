import 'package:cloud_firestore/cloud_firestore.dart';

class FarmLinkUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  FarmLinkUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory FarmLinkUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FarmLinkUser(
      uid: doc.id,
      email: data['email'],
      displayName: data['name'],
      photoUrl: data['photoUrl'],
    );
  }

  @override
  String toString() {
    return 'FarmLinkUser(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }
}
