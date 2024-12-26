import 'package:farm_link/bloc/authentication/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_event.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(
        onPressed: () => context.read<AuthBloc>().add(AuthEventLogout()),
        child: Text('Sign out'),
      ),
    ));
  }
}
