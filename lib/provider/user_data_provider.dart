import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/config/contacts.dart';
import 'package:farm_link/config/paths.dart';
import 'package:farm_link/models/contact.dart';
import 'package:farm_link/models/farmlink_user.dart';
import 'package:farm_link/utils/exceptions.dart';
import 'package:farm_link/utils/shared_objects.dart';
import 'base_provider.dart';

class UserDataProvider extends BaseUserDataProvider {
  final FirebaseFirestore fireStoreDb;

  UserDataProvider({FirebaseFirestore? fireStoreDb})
      : fireStoreDb = fireStoreDb ?? FirebaseFirestore.instance;

  Future<FarmLinkUser> saveProfileDetails(
      String profileImageUrl, String username) async {
    String? uid = SharedObjects.prefs.getString(Constants.sessionUid);
    if (uid == null) throw Exception("Session UID is null");

    DocumentReference<Map<String, dynamic>> mapReference =
        fireStoreDb.collection(Paths.usernameUidMapPath).doc(username);
    await mapReference.set({'uid': uid});

    DocumentReference<Map<String, dynamic>> ref =
        fireStoreDb.collection(Paths.usersPath).doc(uid);
    await ref.set({
      'photoUrl': profileImageUrl,
      'username': username,
    }, SetOptions(merge: true));

    final DocumentSnapshot<Map<String, dynamic>> currentDocument =
        await ref.get();
    SharedObjects.prefs.setString(Constants.sessionUsername, username);
    return FarmLinkUser.fromFirestore(currentDocument);
  }

  @override
  Future<bool> isProfileComplete() async {
    String? uid = SharedObjects.prefs.getString(Constants.sessionUid);
    if (uid == null) throw Exception("Session UID is null");

    DocumentReference<Map<String, dynamic>> ref =
        fireStoreDb.collection(Paths.usersPath).doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> currentDocument =
        await ref.get();
    bool isProfileComplete =
        currentDocument.exists && currentDocument.data()?['username'] != null;

    if (isProfileComplete) {
      SharedObjects.prefs.setString(
          Constants.sessionUsername, currentDocument.data()?['username']);
      SharedObjects.prefs
          .setString(Constants.sessionName, currentDocument.data()?['name']);
    }
    return isProfileComplete;
  }

  @override
  Future<List<Contact>> getContacts() async {
    CollectionReference<Map<String, dynamic>> userRef =
        fireStoreDb.collection(Paths.usersPath);
    String? uid = SharedObjects.prefs.getString(Constants.sessionUid);
    if (uid == null) throw Exception("Session UID is null");

    DocumentReference<Map<String, dynamic>> ref = userRef.doc(uid);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await ref.get();

    List<String> contacts =
        List<String>.from(documentSnapshot.data()?['contacts'] ?? []);

    List<Contact> contactList = [];
    for (String username in contacts) {
      String contactUid = await getUidByUsername(username);
      DocumentSnapshot<Map<String, dynamic>> contactSnapshot =
          await userRef.doc(contactUid).get();
      contactList.add(Contact.fromFirestore(contactSnapshot));
    }
    return contactList;
  }

  void mapDocumentToContact(
      CollectionReference<Map<String, dynamic>> userRef,
      DocumentReference<Map<String, dynamic>> ref,
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
      Sink<List<Contact>> sink) async {
    List<String> contacts =
        List<String>.from(documentSnapshot.data()?['contacts'] ?? []);
    if (contacts.isEmpty) {
      await ref.update({'contacts': []});
    }

    List<Contact> contactList = [];
    for (String username in contacts) {
      String uid = await getUidByUsername(username);
      DocumentSnapshot<Map<String, dynamic>> contactSnapshot =
          await userRef.doc(uid).get();
      contactList.add(Contact.fromFirestore(contactSnapshot));
    }
    contactList.sort((a, b) => a.name.compareTo(b.name));
    sink.add(contactList);
  }

  @override
  Future<void> addContact(String username) async {
    FarmLinkUser contactUser = await getUser(username);
    String? uid = SharedObjects.prefs.getString(Constants.sessionUid);
    if (uid == null) throw Exception("Session UID is null");

    DocumentReference<Map<String, dynamic>> ref =
        fireStoreDb.collection(Paths.usersPath).doc(uid);
    final documentSnapshot = await ref.get();
    List<String> contacts =
        List<String>.from(documentSnapshot.data()?['contacts'] ?? []);
    if (contacts.contains(username)) {
      throw ContactAlreadyExistsException();
    }
    contacts.add(username);
    await ref.set({'contacts': contacts}, SetOptions(merge: true));

    String? sessionUsername =
        SharedObjects.prefs.getString(Constants.sessionUsername);
    DocumentReference<Map<String, dynamic>> contactRef =
        fireStoreDb.collection(Paths.usersPath).doc(contactUser.documentId);
    final contactSnapshot = await contactRef.get();
    contacts = List<String>.from(contactSnapshot.data()?['contacts'] ?? []);
    if (contacts.contains(sessionUsername)) {
      throw ContactAlreadyExistsException();
    }
    contacts.add(sessionUsername!);
    await contactRef.set({'contacts': contacts}, SetOptions(merge: true));
  }

  Future<FarmLinkUser> getUser(String username) async {
    String uid = await getUidByUsername(username);
    DocumentReference<Map<String, dynamic>> ref =
        fireStoreDb.collection(Paths.usersPath).doc(uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
    if (snapshot.exists) {
      return FarmLinkUser.fromFirestore(snapshot);
    } else {
      throw UserNotFoundException();
    }
  }

  Future<String> getUidByUsername(String username) async {
    DocumentReference<Map<String, dynamic>> ref =
        fireStoreDb.collection(Paths.usernameUidMapPath).doc(username);
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await ref.get();

    final data = documentSnapshot.data();
    if (documentSnapshot.exists && data != null && data['uid'] != null) {
      return data['uid'] as String;
    } else {
      throw UsernameMappingUndefinedException();
    }
  }

  @override
  void dispose() {}
}
