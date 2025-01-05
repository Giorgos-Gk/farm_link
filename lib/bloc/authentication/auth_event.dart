import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:farm_link/config/contacts.dart';
import 'package:farm_link/utils/shared_objects.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  AuthEventLogin({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthEventLogout extends AuthEvent {}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final File? image;

  AuthEventRegister({
    required this.email,
    required this.password,
    required this.username,
    this.image,
  });

  @override
  List<Object?> get props => [email, password, username, image];
}

class AuthEventCheckSession extends AuthEvent {
  final user = FirebaseAuth.instance.currentUser;
  final cachedUid = SharedObjects.prefs.getString(Constants.sessionUid);
}

class AuthEventResetPassword extends AuthEvent {
  final String email;

  AuthEventResetPassword({required this.email});

  @override
  List<Object?> get props => [email];
}
