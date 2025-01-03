import 'package:farm_link/bloc/authentication/auth_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_event.dart';
import 'package:farm_link/bloc/authentication/auth_state.dart';
import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/pages/contact_list_page.dart';
import 'package:farm_link/pages/conversation_page_slide.dart';
import 'package:farm_link/utils/shared_objects.dart';
import 'package:farm_link/view/welcome_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedObjects.prefs = await CachedSharedPreferences.getInstance();
  final authBloc = AuthBloc();
  authBloc.add(AuthEventCheckSession());

  runApp(
    BlocProvider.value(
      value: authBloc,
      child: const FarmLink(),
    ),
  );
}

class FarmLink extends StatelessWidget {
  const FarmLink({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark));

    return MaterialApp(
      title: 'FarmLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Palette.primaryColor,
        fontFamily: 'Manrope',
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateLoggedOut) {
            return const WelcomeView();
          } else if (state is AuthStateLoggedIn) {
            return const ConversationPageSlide();
          } else {
            return const ContactListPage();
          }
        },
      ),
    );
  }
}
