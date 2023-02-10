import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/screen/authentication_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/general_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/screens/add_loan_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan/screens/loan_dashboard_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan_calculator/screens/loan_calculator_screen.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/general_lot_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/screens/add_lot_screen.dart';
import 'package:flutter_mon_loan_tracking/features/lot/screens/lot_dashboard_screen.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/main/screens/main_screen.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/settings_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/settings/screens/settings_screen.dart';
import 'package:flutter_mon_loan_tracking/features/splash/bloc/splash_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/splash/screens/splash_screen.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/add_user_screen.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/user_list_screen.dart';
import 'package:flutter_mon_loan_tracking/l10n/l10n.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_schedule_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/lot_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/settings_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
import 'package:flutter_mon_loan_tracking/services/loan_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/loan_schedule_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/lot_cache_service.dart';
import 'package:flutter_mon_loan_tracking/services/lot_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/settings_firestre_service.dart';
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
            child: LoanDashboardScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/lot-dashboard',
            child: LotDashboardScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/users',
            child: UserListScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/settings',
            child: SettingsScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/loan-calculator',
            child: const LoanCalculatorScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/add-loan',
            child: AddLoanScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/add-lot',
            child: AddLotScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/add-user',
            child: AddUserScreen(),
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
        RepositoryProvider<UserRepository>.value(
          value: UserRepository(
            firestoreService: UserFirestoreService(),
          ),
        ),
        RepositoryProvider<SettingsRepository>.value(
          value: SettingsRepository(
            firestoreService: SettingsFireStoreService(),
          ),
        ),
        RepositoryProvider<LotRepository>.value(
          value: LotRepository(
            firestoreService: LotFirestoreService(),
            cacheService: LotCacheService(),
          ),
        ),
        RepositoryProvider<LoanRepository>.value(
          value: LoanRepository(
            firestoreService: LoanFirestoreService(),
          ),
        ),
        RepositoryProvider<LoanScheduleRepository>.value(
          value: LoanScheduleRepository(
            firestoreService: LoanScheduleFirestoreService(),
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
                  authenticationService: context.read<AuthenticationService>(),
                  usersRepository: context.read<UserRepository>(),
                ),
              ),
              BlocProvider<SettingsBloc>.value(
                value: SettingsBloc(
                  settingsRepository: context.read<SettingsRepository>(),
                ),
              ),
              BlocProvider<LotBloc>.value(
                value: LotBloc(
                  lotRepository: context.read<LotRepository>(),
                  settingsRepository: context.read<SettingsRepository>(),
                ),
              ),
              BlocProvider<UserBloc>.value(
                value: UserBloc(
                  userRepository: context.read<UserRepository>(),
                ),
              ),
              BlocProvider<LoanBloc>.value(
                value: LoanBloc(
                  loanRepository: context.read<LoanRepository>(),
                  loanScheduleRepository: context.read<LoanScheduleRepository>(),
                  lotRepository: context.read<LotRepository>(),
                  userRepository: context.read<UserRepository>(),
                  settingsRepository: context.read<SettingsRepository>(),
                  authenticationService: context.read<AuthenticationService>(),
                ),
              ),
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
