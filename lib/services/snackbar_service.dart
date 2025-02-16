import 'package:flutter/material.dart';

class SnackBarService {
  static final SnackBarService instance = SnackBarService();
  late BuildContext _buildContext;

  set buildContext(BuildContext context) {
    _buildContext = context;
  }

  void showSnackBarError(String message) {
    _showSnackBar(message, Colors.red);
  }

  void showSnackBarSuccess(String message) {
    _showSnackBar(message, Colors.green);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(_buildContext).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
