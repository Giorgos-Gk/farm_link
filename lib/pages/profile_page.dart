import 'package:farm_link/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/db_service.dart';
import '../models/contact.dart';

class ProfilePage extends StatelessWidget {
  final double _height;
  final double _width;

  ProfilePage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: _height,
      width: _width,
      child: ChangeNotifierProvider(
        create: (context) => AuthProvider(),
        child: _profilePageUI(),
      ),
    );
  }

  Widget _profilePageUI() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(auth.user!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var _userData = snapshot.data!;
            return Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: _height * 0.50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _userImageWidget(_userData.image),
                    _userNameWidget(_userData.name),
                    _userEmailWidget(_userData.email),
                    _logoutButton(auth),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _userImageWidget(String image) {
    double _imageRadius = _height * 0.20;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_imageRadius),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: image.isNotEmpty
              ? NetworkImage(image)
              : const AssetImage("assets/default_user.png") as ImageProvider,
        ),
      ),
    );
  }

  Widget _userNameWidget(String userName) {
    return SizedBox(
      height: _height * 0.05,
      width: _width,
      child: Text(
        userName,
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
      width: _width * 0.80,
      child: ElevatedButton(
        onPressed: () async {
          // ✅ Κάνουμε το callback async
          await auth.logoutUser(() async {});
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text(
          "LOGOUT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
