import 'package:farm_link/config/pallete.dart';
import 'package:flutter/material.dart';
import 'Styles.dart';

class Decorations {
  static InputDecoration getInputDecoration({
    required String hint,
    required bool isPrimary,
    required BuildContext context,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: isPrimary ? Styles.hintText : Styles.hintTextLight,
      contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isPrimary ? Palette.secondaryColor : Palette.primaryColor,
          width: 0.1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isPrimary ? Palette.secondaryColor : Palette.primaryColor,
          width: 0.1,
        ),
      ),
    );
  }
}
