import 'dart:io';
import 'package:equatable/equatable.dart';

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

class AuthEventCheckSession extends AuthEvent {}

class AuthEventResetPassword extends AuthEvent {
  final String email;

  AuthEventResetPassword({required this.email});

  @override
  List<Object?> get props => [email];
}
