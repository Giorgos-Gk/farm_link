import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../config/contacts.dart';
import '../../utils/shared_objects.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc()
      : super(
          const AuthStateLoggedOut(
            isLoading: false,
            successful: true,
            error: '',
          ),
        ) {
    on<AuthEventLogin>((event, emit) async {
      emit(
        const AuthStateLoggedOut(isLoading: true, successful: true, error: ''),
      );
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        final user = userCredential.user;

        if (user == null) {
          throw Exception('User is null after signIn');
        }
        await SharedObjects.prefs.setString(Constants.sessionUid, user.uid);
        emit(const AuthStateLoggedIn(isLoading: false, successful: true));
        emit(
          const AuthStateLoggedIn(isLoading: false, successful: true),
        );
      } catch (e) {
        emit(
          AuthStateLoggedOut(
            isLoading: false,
            successful: false,
            error: e.toString(),
          ),
        );
      }
    });

    on<AuthEventLogout>((event, emit) async {
      emit(
        const AuthStateLoggedOut(isLoading: true, successful: true, error: ''),
      );
      await _auth.signOut();
      emit(
        const AuthStateLoggedOut(isLoading: false, successful: true, error: ''),
      );
    });

    on<AuthEventRegister>((event, emit) async {
      emit(
        const AuthStateLoggedOut(isLoading: true, successful: true, error: ''),
      );

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        final user = userCredential.user;
        if (user == null) {
          throw Exception('User creation failed');
        }

        await SharedObjects.prefs.setString(Constants.sessionUid, user.uid);

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

        await _storeUserDataInFirestore(
          userId: user.uid,
          username: event.username,
          email: event.email,
          imageUrl: imageUrl,
        );

        emit(const AuthStateLoggedIn(isLoading: false, successful: true));
      } catch (e) {
        emit(
          AuthStateLoggedOut(
            isLoading: false,
            successful: false,
            error: e.toString(),
          ),
        );
      }
    });

    on<AuthEventCheckSession>((event, emit) {
      final user = _auth.currentUser;
      if (user != null) {
        emit(const AuthStateLoggedIn(isLoading: false, successful: true));
      } else {
        emit(
          const AuthStateLoggedOut(
            isLoading: false,
            successful: true,
            error: '',
          ),
        );
      }
    });
  }

  Future<void> _storeUserDataInFirestore({
    required String userId,
    required String username,
    required String email,
    String? imageUrl,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

      await docRef.set({
        'uid': userId,
        'username': username,
        'email': email,
        'image_url': imageUrl ?? '',
        'contacts': [],
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to store user data in Firestore: $e');
    }
  }
}
