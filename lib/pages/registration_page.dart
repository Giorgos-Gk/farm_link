import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_event.dart';
import 'package:farm_link/bloc/authentication/auth_state.dart';
import 'package:farm_link/services/navigation_service.dart';
import 'package:farm_link/services/media_service.dart';
import 'package:farm_link/services/snackbar_service.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name = "";
  String _email = "";
  String _password = "";
  File? _image;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(),
        child: Center(
          child: registrationPageUI(deviceHeight, deviceWidth),
        ),
      ),
    );
  }

  Widget registrationPageUI(double height, double width) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedIn) {
          NavigationService.instance.navigateToReplacement("home");
        } else if (state is AuthStateLoggedOut && !state.successful) {
          SnackBarService.instance.showSnackBarError(state.error);
        }
      },
      builder: (context, state) {
        return Container(
          height: height * 0.75,
          padding: EdgeInsets.symmetric(horizontal: width * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headingWidget(),
              _inputForm(),
              _registerButton(state, width),
              _backToLoginPageButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text(
          "Ας ξεκινήσουμε!",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
        ),
        Text(
          "Παρακαλώ εισάγετε τα στοιχεία σας.",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
        ),
      ],
    );
  }

  Widget _inputForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _imageSelectorWidget(),
          _nameTextField(),
          _emailTextField(),
          _passwordTextField(),
        ],
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return GestureDetector(
      onTap: () async {
        File? imageFile = await MediaService.instance.getImageFromLibrary();
        if (imageFile != null) {
          setState(() {
            _image = imageFile;
          });
        }
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _image != null
            ? FileImage(_image!)
            : const AssetImage("assets/user.png") as ImageProvider,
        child: _image == null ? const Icon(Icons.camera_alt, size: 40) : null,
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (input) => (input != null && input.isNotEmpty)
          ? null
          : "Παρακαλώ εισάγετε όνομα",
      onSaved: (input) => _name = input ?? "",
      decoration: const InputDecoration(labelText: "Όνομα"),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      validator: (input) => (input != null && input.contains("@"))
          ? null
          : "Παρακαλώ εισάγετε email.",
      onSaved: (input) => _email = input ?? "",
      decoration: const InputDecoration(
          labelText: "Email", prefixIcon: Icon(Icons.email)),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      validator: (input) => (input != null && input.length >= 6)
          ? null
          : "Ο κωδικός πρέπει να έχει τουλάχιστον 6 χαρακτήρες.",
      onSaved: (input) => _password = input ?? "",
      decoration: const InputDecoration(labelText: "Κωδικός"),
    );
  }

  Widget _registerButton(AuthState state, double width) {
    return state is AuthStateLoggedOut && state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 50,
            width: width,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  context.read<AuthBloc>().add(
                        AuthEventRegister(
                          email: _email,
                          password: _password,
                          username: _name,
                          image: _image,
                        ),
                      );
                } else {
                  SnackBarService.instance
                      .showSnackBarError("Παρακαλώ συμπληρώστε όλα τα πεδία!");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "ΕΓΓΡΑΦΗ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                ),
              ),
            ),
          );
  }

  Widget _backToLoginPageButton() {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.instance.navigateTo("login");
        },
      ),
    );
  }
}
