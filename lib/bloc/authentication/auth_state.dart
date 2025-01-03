import 'package:equatable/equatable.dart';
import 'package:farm_link/models/farmlink_user.dart';

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

class UnAuthenticated extends AuthState {
  const UnAuthenticated() : super(isLoading: false, successful: false);

  @override
  String toString() => 'UnAuthenticated';
}

class ProfileUpdated extends AuthState {
  const ProfileUpdated() : super(isLoading: false, successful: true);

  @override
  String toString() => 'ProfileComplete';
}

class Authenticated extends AuthState {
  final FarmLinkUser user;

  Authenticated(this.user) : super(isLoading: false, successful: true);

  @override
  String toString() => 'Authenticated';
}
