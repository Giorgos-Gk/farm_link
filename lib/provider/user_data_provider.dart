import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/models/contact.dart';
import 'package:farm_link/models/farmlink_user.dart';
import 'package:farm_link/provider/base_provider.dart';
import 'package:farm_link/utils/exceptions.dart';
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
    final ref = fireStoreDb.collection(Paths.usersPath).doc(user.uid);
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
    final currentDocument = await ref.get();

    await SharedObjects.prefs
        .setString(Constants.sessionUsername, user.displayName ?? '');

    return FarmLinkUser.fromFirestore(currentDocument);
  }

  @override
  Future<FarmLinkUser> saveProfileDetails(
      String profileImageUrl, String username) async {
    final String uid =
        SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    final userRef = fireStoreDb.collection(Paths.usersPath).doc(uid);

    final usernameRef =
        fireStoreDb.collection(Paths.usernameUidMapPath).doc(username);
    await usernameRef.set({'uid': uid});

    var data = {
      'photoUrl': profileImageUrl,
      'username': username,
    };

    await userRef.set(data, SetOptions(merge: true));
    final currentDocument = await userRef.get();

    await SharedObjects.prefs.setString(Constants.sessionUsername, username);
    await SharedObjects.prefs.setString(
        Constants.sessionProfilePictureUrl, currentDocument['photoUrl'] ?? '');

    return FarmLinkUser.fromFirestore(currentDocument);
  }

  @override
  Future<void> updateProfilePicture(String profilePictureUrl) async {
    final String uid =
        SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    final ref = fireStoreDb.collection(Paths.usersPath).doc(uid);
    await ref.set({'photoUrl': profilePictureUrl}, SetOptions(merge: true));
  }

  @override
  Future<bool> isProfileComplete() async {
    final String uid =
        SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    final ref = fireStoreDb.collection(Paths.usersPath).doc(uid);
    final documentSnapshot = await ref.get();

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

  Future<List<Contact>> getContacts() async {
    final ref = fireStoreDb
        .collection(Paths.usersPath)
        .doc(SharedObjects.prefs.getString(Constants.sessionUid) ?? '');
    final snapshot = await ref.get();

    List<String> contacts = [];
    if (snapshot.exists && snapshot.data() != null) {
      contacts = List<String>.from(snapshot.data()!['contacts'] ?? []);
    } else {
      await ref.set({'contacts': []}, SetOptions(merge: true));
    }

    return await Future.wait(contacts.map((username) async {
      final uid = await getUidByUsername(username);
      final contactSnapshot =
          await fireStoreDb.collection(Paths.usersPath).doc(uid).get();
      return Contact.fromFirestore(contactSnapshot);
    }));
  }

  Future<void> addContact(String username) async {
    final ref = fireStoreDb
        .collection(Paths.usersPath)
        .doc(SharedObjects.prefs.getString(Constants.sessionUid) ?? '');
    final snapshot = await ref.get();

    List<String> contacts = [];
    if (snapshot.exists && snapshot.data() != null) {
      contacts = List<String>.from(snapshot.data()!['contacts'] ?? []);
    }

    if (contacts.contains(username)) {
      throw ContactAlreadyExistsException();
    }

    contacts.add(username);
    await ref.update({'contacts': contacts});
  }

  Future<FarmLinkUser> getUser(String username) async {
    final uid = await getUidByUsername(username);
    final ref = fireStoreDb.collection(Paths.usersPath).doc(uid);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      return FarmLinkUser.fromFirestore(snapshot);
    } else {
      throw UserNotFoundException();
    }
  }

  Future<String> getUidByUsername(String username) async {
    final ref = fireStoreDb.collection(Paths.usernameUidMapPath).doc(username);
    final documentSnapshot = await ref.get();

    if (documentSnapshot.exists &&
        documentSnapshot.data() != null &&
        documentSnapshot.data()!['uid'] != null) {
      return documentSnapshot.data()!['uid'];
    } else {
      throw UsernameMappingUndefinedException();
    }
  }
}
