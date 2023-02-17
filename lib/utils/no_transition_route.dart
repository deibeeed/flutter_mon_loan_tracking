import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/user_details_screen.dart';
import 'package:go_router/go_router.dart';

class RouteUtils {
  static GoRoute buildNoTransitionRoute({
    required String path,
    required Widget child,
    List<GoRoute> routes = const [],
  }) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) {
        if (child is UserDetailsScreen) {
          final userId = state.params['userId'];

          if (userId != null) {
            child.userId = userId;
          }
        }

        return NoTransitionPage(child: child);
      },
      routes: routes
    );
  }
}
