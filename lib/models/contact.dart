import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String username;
  final String name;
  final String documentId;

  Contact({
    required this.documentId,
    required this.username,
    required this.name,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Contact(
      documentId: doc.id,
      username: data['username'] ?? '',
      name: data['name'] ?? '',
    );
  }

  @override
  String toString() {
    return '{ documentId: $documentId, name: $name, username: $username }';
  }

  String getFirstName() => name.split(' ')[0];

  String getLastName() {
    final names = name.split(' ');
    return names.length > 1 ? names[1] : '';
  }
}
