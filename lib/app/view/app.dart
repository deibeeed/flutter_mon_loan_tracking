import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/screen/authentication_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/general_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/loan/screens/add_loan_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan/screens/loan_dashboard_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan_calculator/screens/loan_calculator_screen.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/general_lot_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/lot/screens/add_lot_screen.dart';
import 'package:flutter_mon_loan_tracking/features/lot/screens/lot_dashboard_screen.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/main/screens/main_screen.dart';
import 'package:flutter_mon_loan_tracking/features/settings/screens/settings_screen.dart';
import 'package:flutter_mon_loan_tracking/features/splash/bloc/splash_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/splash/screens/splash_screen.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/add_user_screen.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/user_list_screen.dart';
import 'package:flutter_mon_loan_tracking/l10n/l10n.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
import 'package:flutter_mon_loan_tracking/services/user_firestore_service.dart';
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
    initialLocation: '/login',
    routes: [
      // GoRoute(
      //   path: '/splash',
      //   builder: (context, state) {
      //     return const SplashScreen();
      //   },
      // ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return AuthenticationScreen();
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
          RouteUtils.buildNoTransitionRoute(
            path: '/add-loan',
            child: const AddLoanScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/add-lot',
            child: const AddLotScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/add-user',
            child: const AddUserScreen(),
          ),
        ],
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationService>.value(
          value: AuthenticationService(),
        ),
        RepositoryProvider<UsersRepository>.value(
          value: UsersRepository(
            firestoreService: UserFirestoreService(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<SplashBloc>.value(
                value: SplashBloc(),
              ),
              BlocProvider<MenuSelectionCubit>.value(
                value: MenuSelectionCubit(),
              ),
              BlocProvider<GeneralFilterSelectionCubit>.value(
                value: GeneralFilterSelectionCubit(),
              ),
              BlocProvider<GeneralLotFilterSelectionCubit>.value(
                value: GeneralLotFilterSelectionCubit(),
              ),
              BlocProvider<AuthenticationBloc>.value(
                value: AuthenticationBloc(
                  authenticationService: AuthenticationService(),
                  usersRepository: context.read<UsersRepository>(),
                ),
              )
            ],
            child: MaterialApp.router(
              routerConfig: _rootRouter,
              theme:
                  ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
              darkTheme:
                  ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              // home: const MainScreen(),
            ),
          );
        },
      ),
    );
  }
}
