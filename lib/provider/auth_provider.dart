import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';
import '../services/db_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  User? user;
  AuthStatus status = AuthStatus.NotAuthenticated;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final AuthProvider instance = AuthProvider();

  AuthProvider() {
    user = _auth.currentUser;
    if (user != null) {
      status = AuthStatus.Authenticated;
      notifyListeners();
    }
    _checkCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (user != null) {
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      NavigationService.instance.navigateToReplacement("home");
    }
  }

  void _checkCurrentUserIsAuthenticated() {
    _auth.authStateChanges().listen((User? currentUser) {
      user = currentUser;
      if (user != null) {
        status = AuthStatus.Authenticated;
        notifyListeners();
        // _autoLogin();
      }
    });
  }

  Future<void> loginUserWithEmailAndPassword(
      String email, String password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await _saveFcmToken(user!.uid);
      SnackBarService.instance
          .showSnackBarSuccess("Καλώς ήρθατε, ${user?.email}");
      _autoLogin();
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance
          .showSnackBarError("Error Authenticating: ${e.toString()}");
    }
    notifyListeners();
  }

  Future<void> registerUserWithEmailAndPassword(String email, String password,
      Future<void> Function(String uid) onSuccess) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await _saveFcmToken(user!.uid);
      await onSuccess(user!.uid);
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user?.email}");
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance
          .showSnackBarError("Error Registering User: ${e.toString()}");
    }
    notifyListeners();
  }

  Future<void> _saveFcmToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update({'fcmToken': token});
    }
  }

  Future<void> logoutUser(Future<void> Function() onSuccess) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      NavigationService.instance.navigateToReplacement("login");
      SnackBarService.instance.showSnackBarSuccess("Logged Out Successfully!");
    } catch (e) {
      SnackBarService.instance
          .showSnackBarError("Error Logging Out: ${e.toString()}");
    }
    notifyListeners();
  }
}
