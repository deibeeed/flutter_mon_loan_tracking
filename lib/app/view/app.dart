import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/screen/authentication_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan_calculator/screens/loan_calculator_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan_dashboard/screens/loan_dashboard_screen.dart';
import 'package:flutter_mon_loan_tracking/features/lot_dashboard/screens/lot_dashboard_screen.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/main/screens/main_screen.dart';
import 'package:flutter_mon_loan_tracking/features/settings/screens/settings_screen.dart';
import 'package:flutter_mon_loan_tracking/features/splash/bloc/splash_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/splash/screens/splash_screen.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/user_list_screen.dart';
import 'package:flutter_mon_loan_tracking/l10n/l10n.dart';
import 'package:flutter_mon_loan_tracking/utils/color_schemes.g.dart';
import 'package:flutter_mon_loan_tracking/utils/no_transition_route.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  App({super.key});

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  final GoRouter _rootRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const AuthenticationScreen();
        },
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(content: child);
        },
        routes: [
          RouteUtils.buildNoTransitionRoute(
            path: '/loan-dashboard',
            child: const LoanDashboardScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/lot-dashboard',
            child: const LotDashboardScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/users',
            child: UserListScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/settings',
            child: const SettingsScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/loan-calculator',
            child: const LoanCalculatorScreen(),
          ),
        ],
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>.value(value: SplashBloc()),
        BlocProvider<MenuSelectionCubit>.value(value: MenuSelectionCubit())
      ],
      child: MaterialApp.router(
        routerConfig: _rootRouter,
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // home: const MainScreen(),
      ),
    );
  }
}
