import 'package:farm_link/auth/auth.dart';
import 'package:farm_link/bloc/authentication/auth_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_state.dart';
import 'package:farm_link/pages/contact_list_page.dart';
import 'package:farm_link/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenController extends StatelessWidget {
  const ScreenController({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthStateLoggedIn) {
              return HomeView();
            }
            if (state is AuthStateLoggedOut) {
              return ContactListPage();
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
