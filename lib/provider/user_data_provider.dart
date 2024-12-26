import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/models/farmlink_user.dart';
import 'package:farm_link/provider/base_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_link/config/constants.dart';
import 'package:farm_link/config/paths.dart';
import 'package:farm_link/utils/shared_objects.dart';

class UserDataProvider extends BaseUserDataProvider {
  final FirebaseFirestore fireStoreDb;

  UserDataProvider({FirebaseFirestore? fireStoreDb})
      : fireStoreDb = fireStoreDb ?? FirebaseFirestore.instance;

  @override
  Future<FarmLinkUser> saveDetailsFromGoogleAuth(User user) async {
    final DocumentReference ref =
        fireStoreDb.collection(Paths.usersPath).doc(user.uid);
    final bool userExists = (await ref.get()).exists;

    var data = {
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
    };

    if (!userExists && user.photoURL != null) {
      data['photoUrl'] = user.photoURL;
    }

    await ref.set(data, SetOptions(merge: true));
    final DocumentSnapshot currentDocument = await ref.get();

    await SharedObjects.prefs
        .setString(Constants.sessionUsername, user.displayName ?? '');

    return FarmLinkUser.fromFirestore(currentDocument);
  }

  @override
  Future<FarmLinkUser> saveProfileDetails(
      String profileImageUrl, String username) async {
    final String uid =
        SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    final DocumentReference userRef =
        fireStoreDb.collection(Paths.usersPath).doc(uid);

    final DocumentReference usernameRef =
        fireStoreDb.collection(Paths.usernameUidMapPath).doc(username);
    await usernameRef.set({'uid': uid});

    var data = {
      'photoUrl': profileImageUrl,
      'username': username,
    };

    await userRef.set(data, SetOptions(merge: true));
    final DocumentSnapshot currentDocument = await userRef.get();

    await SharedObjects.prefs.setString(Constants.sessionUsername, username);
    await SharedObjects.prefs.setString(
        Constants.sessionProfilePictureUrl, currentDocument['photoUrl'] ?? '');

    return FarmLinkUser.fromFirestore(currentDocument);
  }

  @override
  Future<void> updateProfilePicture(String profilePictureUrl) async {
    final String uid =
        SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    final DocumentReference ref =
        fireStoreDb.collection(Paths.usersPath).doc(uid);
    await ref.set({'photoUrl': profilePictureUrl}, SetOptions(merge: true));
  }

  @override
  Future<bool> isProfileComplete() async {
    final String uid =
        SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    final DocumentReference ref =
        fireStoreDb.collection(Paths.usersPath).doc(uid);
    final DocumentSnapshot documentSnapshot = await ref.get();

    final bool isComplete = documentSnapshot.exists &&
        documentSnapshot.data() != null &&
        documentSnapshot['photoUrl'] != null &&
        documentSnapshot['username'] != null;

    if (isComplete) {
      await SharedObjects.prefs
          .setString(Constants.sessionUsername, documentSnapshot['username']);
      await SharedObjects.prefs.setString(
          Constants.sessionProfilePictureUrl, documentSnapshot['photoUrl']);
    }

    return isComplete;
  }

  @override
  void dispose() {}
}
