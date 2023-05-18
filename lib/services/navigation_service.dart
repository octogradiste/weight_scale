import 'package:flutter/material.dart';

abstract class INavigationService {
  GlobalKey<NavigatorState> get navigatorKey;

  Future<dynamic> navigateTo(Widget page);

  void pop();

  void showPopUpDialog(Widget widget);
}

class NavigationService implements INavigationService {
  static final GlobalKey<NavigatorState> _navigatorState = GlobalKey();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorState;

  @override
  Future<dynamic> navigateTo(Widget page) {
    return _navigatorState.currentState!
        .push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  void pop() {
    _navigatorState.currentState!.pop();
  }

  @override
  void showPopUpDialog(Widget widget) {
    showDialog(
      context: _navigatorState.currentContext!,
      builder: (_) => widget,
    );
  }
}
