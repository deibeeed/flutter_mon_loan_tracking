import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteUtils {
  static GoRoute buildNoTransitionRoute({
    required String path,
    required Widget child,
  }) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => NoTransitionPage(child: child),
    );
  }
}
