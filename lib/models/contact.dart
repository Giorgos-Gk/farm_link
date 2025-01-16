import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String username;
  final String name;
  final String documentId;
  final String? photoUrl;

  Contact({
    required this.documentId,
    required this.username,
    required this.name,
    this.photoUrl,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Contact(
      documentId: doc.id,
      username: data['username'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  get chatId => null;

  @override
  String toString() {
    return '{ documentId: $documentId, name: $name, username: $username ,  $photoUrl: photoUrl,}';
  }

  String getFirstName() => name.split(' ')[0];

  String getLastName() {
    final names = name.split(' ');
    return names.length > 1 ? names[1] : '';
  }
}
