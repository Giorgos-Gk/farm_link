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
      Reference storageRef = _storage.ref().child(_profileImages).child(uid);
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
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
      Reference storageRef = _storage
          .ref()
          .child(_messages)
          .child(uid)
          .child(_images)
          .child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading media message: $e");
      return null;
    }
  }
}
