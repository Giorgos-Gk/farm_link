import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_link/pages/login_page.dart';
import 'package:farm_link/pages/registration_page.dart';
import 'package:farm_link/pages/home_page.dart';
import 'package:farm_link/services/navigation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    return MaterialApp(
      title: 'Farm Link',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 20, 179, 86),
        scaffoldBackgroundColor: const Color(0xFF1C1B1B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2A75BC),
          secondary: Color(0xFF2A75BC),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? "home" : "login",
      routes: {
        "login": (context) => LoginPage(),
        "register": (context) => BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(),
              child: RegistrationPage(),
            ),
        "home": (context) => HomePage(),
      },
    );
  }
}
