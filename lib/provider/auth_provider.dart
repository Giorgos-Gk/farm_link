import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user?.email}");
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
      await onSuccess(user!.uid);
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user?.email}");
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      // NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance
          .showSnackBarError("Error Registering User: ${e.toString()}");
    }
    notifyListeners();
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
