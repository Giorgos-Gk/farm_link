import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String _profileImages = "profile_images";
  final String _messages = "messages";
  final String _images = "images";

  Future<String?> uploadUserImage(String uid, File image) async {
    try {
      // Δημιουργία reference για το αρχείο
      Reference storageRef = _storage.ref().child(_profileImages).child(uid);

      // Ανέβασμα αρχείου στο Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);

      // Περιμένουμε να ολοκληρωθεί το ανέβασμα
      TaskSnapshot snapshot = await uploadTask;

      // Λήψη του URL του αρχείου
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading profile image: $e");
      return null;
    }
  }

  Future<String?> uploadMediaMessage(String uid, File file) async {
    try {
      String fileName =
          "${basename(file.path)}_${DateTime.now().millisecondsSinceEpoch}";

      // Δημιουργία reference για το αρχείο
      Reference storageRef = _storage
          .ref()
          .child(_messages)
          .child(uid)
          .child(_images)
          .child(fileName);

      // Ανέβασμα αρχείου στο Firebase Storage
      UploadTask uploadTask = storageRef.putFile(file);

      // Περιμένουμε να ολοκληρωθεί το ανέβασμα
      TaskSnapshot snapshot = await uploadTask;

      // Λήψη του URL του αρχείου
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading media message: $e");
      return null;
    }
  }
}
