import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_link/provider/auth_provider.dart';
import '../services/db_service.dart';
import '../models/contact.dart';

class ProfilePage extends StatelessWidget {
  final double _height;
  final double _width;

  const ProfilePage(this._height, this._width, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Αν δεν υπάρχει user, εμφάνιση loader
            if (auth.user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // StreamBuilder για τα δεδομένα του χρήστη
            return StreamBuilder<Contact>(
              stream: DBService.instance.getUserData(auth.user!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Σφάλμα: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Δεν βρέθηκαν δεδομένα'));
                }

                final userData = snapshot.data!;
                return Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: _height * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _userImageWidget(userData.image),
                        _userNameWidget(userData.name),
                        _userEmailWidget(userData.email),
                        _logoutButton(auth),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _userImageWidget(String image) {
    final double radius = _height * 0.2;
    // Αν το string είναι URL (ξεκινάει με http), κάνε NetworkImage,
    // αλλιώς AssetImage
    final provider = (image.startsWith('http'))
        ? NetworkImage(image)
        : const AssetImage('assets/user.png') as ImageProvider;
    return Container(
      height: radius,
      width: radius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: provider,
        ),
      ),
    );
  }

  Widget _userNameWidget(String name) {
    return SizedBox(
      height: _height * 0.05,
      width: _width,
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  Widget _userEmailWidget(String email) {
    return SizedBox(
      height: _height * 0.03,
      width: _width,
      child: Text(
        email,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white24, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton(AuthProvider auth) {
    return SizedBox(
      height: _height * 0.06,
      width: _width * 0.8,
      child: ElevatedButton(
        onPressed: () async {
          await auth.logoutUser(() async {});
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text(
          'AΠΟΣΥΝΔΕΣΗ',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white60),
        ),
      ),
    );
  }
}
