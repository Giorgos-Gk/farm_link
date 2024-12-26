import 'package:farm_link/view/login_view.dart';
import 'package:farm_link/view/register_view.dart';
import 'package:flutter/material.dart';

import '../auth/auth_error.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 500,
              fit: BoxFit.cover,
            ),
            const Text(
              'Kαλωσήρθατε στο Farm Link.',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 50,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: 300,
                height: 50,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      _createCustomPageTransition(
                        const RegisterView(),
                      ),
                    );
                  },
                  color: Colors.green,
                  child: const Center(
                    child: Text(
                      'Δημιουργία Λογαριασμού',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  _createCustomPageTransition(
                    const LoginView(),
                  ),
                );
              },
              child: const Text(
                'Εχω ηδη λογαριασμό',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: authErrorRegister != ''
                  ? Text(
                      authErrorRegister.split(']')[1],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  : null,
            )
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _createCustomPageTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
