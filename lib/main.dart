import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_link/pages/login_page.dart';
import 'package:farm_link/pages/home_page.dart';
import 'package:farm_link/pages/registration_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_bloc.dart';
import 'package:farm_link/services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FarmLink());
}

class FarmLink extends StatelessWidget {
  const FarmLink({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Link',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromARGB(255, 20, 179, 86),
        scaffoldBackgroundColor: const Color(0xFF1C1B1B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2A75BC),
          secondary: Color(0xFF2A75BC),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Περιμένουμε το πρώτο event
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Αν έχουμε user → home, αλλιώς login
          if (snapshot.hasData && snapshot.data != null) {
            return HomePage();
          }
          return LoginPage();
        },
      ),
      routes: {
        'login': (_) => LoginPage(),
        'register': (_) => BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(),
              child: RegistrationPage(),
            ),
        'home': (_) => HomePage(),
      },
    );
  }
}
