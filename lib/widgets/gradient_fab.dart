import 'package:farm_link/config/pallete.dart';
import 'package:flutter/material.dart';

class GradientFab extends StatelessWidget {
  final Animation<double> animation;

  const GradientFab({
    Key? key,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: FloatingActionButton(
        onPressed: () {
          // π.χ. άνοιγμα νέας οθόνης ή άλλη λογική
        },
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomRight,
              colors: [
                Palette.gradientStartColor,
                Palette.gradientEndColor,
              ],
            ),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
