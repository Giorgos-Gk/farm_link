import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService instance = NavigationService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateToReplacement(String routeName) {
    return navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  Future<dynamic>? navigateTo(String routeName) {
    return navigatorKey.currentState?.pushNamed(routeName);
  }

  Future<dynamic>? navigateToRoute(Route route) {
    return navigatorKey.currentState?.push(route);
  }

  void goBack() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }
}
