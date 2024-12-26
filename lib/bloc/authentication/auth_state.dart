import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  final bool isLoading;
  final bool successful;

  const AuthState({required this.isLoading, required this.successful});

  @override
  List<Object?> get props => [isLoading, successful];
}

class AuthStateLoggedIn extends AuthState {
  const AuthStateLoggedIn({
    required bool isLoading,
    required bool successful,
  }) : super(isLoading: isLoading, successful: successful);

  @override
  List<Object?> get props => [isLoading, successful];
}

class AuthStateLoggedOut extends AuthState {
  final String error;
  const AuthStateLoggedOut({
    required bool isLoading,
    required bool successful,
    required this.error,
  }) : super(isLoading: isLoading, successful: successful);

  @override
  List<Object?> get props => [isLoading, successful, error];
}

class AuthStateResetPassword extends AuthState {
  final String message;

  const AuthStateResetPassword({
    required this.message,
    required bool isLoading,
    required bool successful,
  }) : super(isLoading: isLoading, successful: successful);

  @override
  List<Object?> get props => [message, isLoading, successful];
}
