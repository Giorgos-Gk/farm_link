import 'dart:io';
import 'package:farm_link/config/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../provider/authentication_provider.dart';

class AuthenticationRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;
  final AuthenticationProvider authenticationProvider;

  AuthenticationRepository({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    required this.authenticationProvider,
  })  : firebaseAuth = auth ?? FirebaseAuth.instance,
        firebaseStorage = storage ?? FirebaseStorage.instance;

  Future<void> updateUserProfile({
    required String username,
    required String profileImageUrl,
  }) async {
    User? user = firebaseAuth.currentUser;

    if (user != null) {
      await user.updateDisplayName(username);
      await user.updatePhotoURL(profileImageUrl);
      await user.reload();
    } else {
      throw Exception('No user is currently signed in.');
    }
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    return await authenticationProvider.signUpWithEmailAndPassword(
        email, password);
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    return await authenticationProvider.signInWithEmailAndPassword(
        email, password);
  }

  Future<void> signOut() async {
    return await authenticationProvider.signOut();
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
    return authenticationProvider.getCurrentUser();
  }
}
