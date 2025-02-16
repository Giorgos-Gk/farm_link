import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_link/provider/auth_provider.dart';
import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AuthProvider _auth;
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    double _deviceHeight = MediaQuery.of(context).size.height;
    double _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Align(
        alignment: Alignment.center,
        child: ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          child: _loginPageUI(_deviceHeight, _deviceWidth),
        ),
      ),
    );
  }

  Widget _loginPageUI(double height, double width) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        SnackBarService.instance.buildContext = context;
        _auth = auth;
        return Container(
          height: height * 0.60,
          padding: EdgeInsets.symmetric(horizontal: width * 0.10),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headingWidget(height),
              _inputForm(height),
              _loginButton(width),
              _registerButton(width),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget(double height) {
    return SizedBox(
      height: height * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text("Καλώς ήρθατε στο Farm Link!",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
          Text("Παρακαλώ συνδεθείτε.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
        ],
      ),
    );
  }

  Widget _inputForm(double height) {
    return SizedBox(
      height: height * 0.16,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState?.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (_input) => (_input != null && _input.contains("@"))
          ? null
          : "Please enter a valid email",
      onSaved: (_input) => setState(() => _email = _input ?? ""),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: " Διεύθυνση ηλεκτρονικού ταχυδρομείου",
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      validator: (_input) => (_input != null && _input.isNotEmpty)
          ? null
          : "Παρακαλούμε εισάγετε κωδικό",
      onSaved: (_input) => setState(() => _password = _input ?? ""),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Κωδικός",
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _loginButton(double width) {
    return _auth.status == AuthStatus.Authenticating
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 50,
            width: width,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _auth.loginUserWithEmailAndPassword(_email, _password);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("ΣΥΝΔΕΣΗ",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white60)),
            ),
          );
  }

  Widget _registerButton(double width) {
    return GestureDetector(
      onTap: () => NavigationService.instance.navigateTo("register"),
      child: SizedBox(
        height: 50,
        width: width,
        child: const Center(
          child: Text(
            "ΕΓΓΡΑΦΗ",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white60),
          ),
        ),
      ),
    );
  }
}
