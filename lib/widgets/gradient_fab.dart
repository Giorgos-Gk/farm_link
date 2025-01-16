import 'package:flutter/material.dart';
import 'package:farm_link/config/pallete.dart';

class GradientFab extends StatelessWidget {
  const GradientFab({
    Key? key,
    this.animation,
    this.elevation = 6.0,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  final Animation<double>? animation;
  final double elevation;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fab = FloatingActionButton(
      elevation: elevation,
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 56.0,
          minHeight: 56.0,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.gradientStartColor,
              Palette.gradientEndColor,
            ],
          ),
        ),
        child: child,
      ),
    );

    return animation != null
        ? AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
            child: ScaleTransition(scale: animation!, child: fab),
          )
        : fab;
  }
}
