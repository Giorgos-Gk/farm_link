import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final Timestamp lastSeen;
  final String name;

  Contact({
    required this.id,
    required this.email,
    required this.name,
    required this.image,
    required this.lastSeen,
  });

  factory Contact.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Contact(
      id: snapshot.id,
      lastSeen: (data?['lastSeen'] as Timestamp?) ?? Timestamp.now(),
      email: (data?['email'] as String?) ?? 'Unknown',
      name: (data?['name'] as String?) ?? 'Unknown',
      image: (data?['image'] as String?) ?? '',
    );
  }
}
