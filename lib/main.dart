import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/pages/register_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(Farmlink());

class Farmlink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmlink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Palette.primaryColor,
      ),
      home: RegisterPage(),
    );
  }
}
