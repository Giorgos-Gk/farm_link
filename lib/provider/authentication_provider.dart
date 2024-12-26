import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:farm_link/config/constants.dart';

class AuthenticationProvider {
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  AuthenticationProvider({FirebaseAuth? auth, FirebaseStorage? storage})
      : firebaseAuth = auth ?? FirebaseAuth.instance,
        firebaseStorage = storage ?? FirebaseStorage.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    final UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    final UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<String> uploadProfileImage(File profileImage) async {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final Reference ref =
        firebaseStorage.ref().child(Constants.profileImagePath).child(fileName);
    final UploadTask uploadTask = ref.putFile(profileImage);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }
}
