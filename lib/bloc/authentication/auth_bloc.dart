import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:farm_link/services/db_service.dart';
import 'package:farm_link/services/navigation_service.dart';
import 'package:farm_link/services/snackbar_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(const UnAuthenticated()) {
    on<AuthEventLogin>(_onLogin);
    on<AuthEventRegister>(_onRegister);
    on<AuthEventLogout>(_onLogout);
    on<AuthEventCheckSession>(_onCheckSession);
  }

  Future<void> _onLogin(AuthEventLogin event, Emitter<AuthState> emit) async {
    emit(
        const AuthStateLoggedOut(isLoading: true, successful: true, error: ''));
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw Exception("User is null after sign in");
      }
      await DBService.instance.updateUserLastSeenTime(user.uid);
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user.email}");
      NavigationService.instance.navigateToReplacement("home");
      emit(const AuthStateLoggedIn(isLoading: false, successful: true));
    } catch (e) {
      SnackBarService.instance
          .showSnackBarError("Error Authenticating: ${e.toString()}");
      emit(AuthStateLoggedOut(
          isLoading: false, successful: false, error: e.toString()));
    }
  }

  Future<void> _onRegister(
      AuthEventRegister event, Emitter<AuthState> emit) async {
    emit(
        const AuthStateLoggedOut(isLoading: true, successful: true, error: ''));
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed");
      }
      String? imageUrl;
      if (event.image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.png');
        await storageRef.putFile(event.image!);
        imageUrl = await storageRef.getDownloadURL();
      }
      await user.updateDisplayName(event.username);
      if (imageUrl != null) {
        await user.updatePhotoURL(imageUrl);
      }
      await DBService.instance.createUserInDB(
        user.uid,
        event.username,
        event.email,
        imageUrl ?? "assets/user.png",
      );
      await DBService.instance.updateUserLastSeenTime(user.uid);

      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user.email}");
      NavigationService.instance.navigateToReplacement("home");
      emit(const AuthStateLoggedIn(isLoading: false, successful: true));
    } catch (e) {
      SnackBarService.instance
          .showSnackBarError("Error Registering User: ${e.toString()}");
      emit(AuthStateLoggedOut(
          isLoading: false, successful: false, error: e.toString()));
    }
  }

  Future<void> _onLogout(AuthEventLogout event, Emitter<AuthState> emit) async {
    emit(
        const AuthStateLoggedOut(isLoading: true, successful: true, error: ''));
    try {
      await _auth.signOut();
      SnackBarService.instance.showSnackBarSuccess("Logged Out Successfully!");
      NavigationService.instance.navigateToReplacement("login");
      emit(const UnAuthenticated());
    } catch (e) {
      SnackBarService.instance
          .showSnackBarError("Error Logging Out: ${e.toString()}");
      emit(AuthStateLoggedOut(
          isLoading: false, successful: false, error: e.toString()));
    }
  }

  Future<void> _onCheckSession(
      AuthEventCheckSession event, Emitter<AuthState> emit) async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(const AuthStateLoggedIn(isLoading: false, successful: true));
    } else {
      emit(const UnAuthenticated());
    }
  }
}
