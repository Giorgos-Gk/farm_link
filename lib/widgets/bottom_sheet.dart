import 'dart:async';
import 'package:flutter/material.dart';

const Duration _kBottomSheetDuration = Duration(milliseconds: 200);

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, this.bottomInset);

  final double progress;
  final double bottomInset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(
      0.0,
      size.height - bottomInset - childSize.height * progress,
    );
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress ||
        bottomInset != oldDelegate.bottomInset;
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({Key? key, required this.route}) : super(key: key);

  final _ModalBottomSheetRoute<T> route;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.route.dismissOnTap ? () => Navigator.pop(context) : null,
      child: AnimatedBuilder(
        animation: widget.route.animation!,
        builder: (BuildContext context, Widget? child) {
          final bottomInset = widget.route.resizeToAvoidBottomInset
              ? MediaQuery.of(context).viewInsets.bottom
              : 0.0;
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _ModalBottomSheetLayout(
                widget.route.animation!.value,
                bottomInset,
              ),
              child: BottomSheet(
                animationController: widget.route._animationController,
                onClosing: () => Navigator.pop(context),
                builder: widget.route.builder,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModalBottomSheetRoute<T> extends PopupRoute<T> {
  _ModalBottomSheetRoute({
    required this.builder,
    required this.theme,
    required this.barrierLabel,
    required this.resizeToAvoidBottomInset,
    required this.dismissOnTap,
    RouteSettings? settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData theme;
  final bool resizeToAvoidBottomInset;
  final bool dismissOnTap;

  @override
  Duration get transitionDuration => _kBottomSheetDuration;

  @override
  bool get barrierDismissible => false;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  late final AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(navigator != null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _ModalBottomSheet<T>(route: this),
    );
    bottomSheet = Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }
}

Future<T?> showModalBottomSheetApp<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissOnTap = false,
  bool resizeToAvoidBottomInset = true,
}) {
  return Navigator.push(
    context,
    _ModalBottomSheetRoute<T>(
      builder: builder,
      theme: Theme.of(context),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      dismissOnTap: dismissOnTap,
    ),
  );
}
