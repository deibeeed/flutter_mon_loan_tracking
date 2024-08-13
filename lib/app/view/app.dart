import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/screen/authentication_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/general_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/screens/add_loan_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan/screens/loan_dashboard_screen.dart';
import 'package:flutter_mon_loan_tracking/features/loan_calculator/screens/loan_calculator_screen.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/main/screens/main_screen.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/settings_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/settings/screens/settings_screen.dart';
import 'package:flutter_mon_loan_tracking/features/splash/bloc/splash_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/splash/screens/splash_screen.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/add_user_screen.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/user_details_screen.dart';
import 'package:flutter_mon_loan_tracking/features/users/screens/user_list_screen.dart';
import 'package:flutter_mon_loan_tracking/l10n/l10n.dart';
import 'package:flutter_mon_loan_tracking/repositories/address_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/beneficiary_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/employment_details_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_schedule_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/settings_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/address_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
import 'package:flutter_mon_loan_tracking/services/beneficiary_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/employment_details_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/loan_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/loan_schedule_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/settings_cache_service.dart';
import 'package:flutter_mon_loan_tracking/services/settings_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/services/user_cache_service.dart';
import 'package:flutter_mon_loan_tracking/services/user_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/utils/color_schemes.g.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/no_transition_route.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  App({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  late final GoRouter _rootRouter;

  @override
  void initState() {
    super.initState();

    _rootRouter = GoRouter(
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
              path: '/users',
              child: UserListScreen(),
            ),
            RouteUtils.buildNoTransitionRoute(
              path: '/settings',
              child: SettingsScreen(),
            ),
            RouteUtils.buildNoTransitionRoute(
              path: '/loan-calculator',
              child: LoanCalculatorScreen(),
            ),
            if (!widget.isMobile()) ...[
              RouteUtils.buildNoTransitionRoute(
                path: '/add-loan',
                child: AddLoanScreen(),
              ),
              RouteUtils.buildNoTransitionRoute(
                path: '/add-user',
                child: AddUserScreen(),
              ),
              RouteUtils.buildNoTransitionRoute(
                path: '/users/:userId',
                child: UserDetailsScreen(),
              ),
              RouteUtils.buildNoTransitionRoute(
                path: '/profile/:userId',
                child: UserDetailsScreen(),
              ),
            ],
          ],
        ),
        if (widget.isMobile()) ...[
          RouteUtils.buildNoTransitionRoute(
            path: '/add-loan',
            parentNavigatorKey: rootNavigatorKey,
            child: AddLoanScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/add-user',
            parentNavigatorKey: rootNavigatorKey,
            child: AddUserScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/users/:userId',
            parentNavigatorKey: rootNavigatorKey,
            child: UserDetailsScreen(),
          ),
          RouteUtils.buildNoTransitionRoute(
            path: '/profile/:userId',
            parentNavigatorKey: rootNavigatorKey,
            child: UserDetailsScreen(),
          ),
        ],
      ],
    );
  }

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
            cacheService: UserCacheService(),
          ),
        ),
        RepositoryProvider<SettingsRepository>.value(
          value: SettingsRepository(
            firestoreService: SettingsFireStoreService(),
            cacheService: SettingsCacheService(),
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
        RepositoryProvider<AddressRepository>.value(
          value: AddressRepository(
            firestoreService: AddressFirestoreService(),
          ),
        ),
        RepositoryProvider<BeneficiariesRepository>.value(
          value: BeneficiariesRepository(
            firestoreService: BeneficiariesFirestoreService(),
          ),
        ),
        RepositoryProvider<EmploymentDetailsRepository>.value(
          value: EmploymentDetailsRepository(
            firestoreService: EmploymentDetailsFirestoreService(),
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
              BlocProvider<UserBloc>.value(
                value: UserBloc(
                  userRepository: context.read<UserRepository>(),
                  authenticationService: context.read<AuthenticationService>(),
                  addressRepository: context.read<AddressRepository>(),
                  beneficiaryRepository:
                      context.read<BeneficiariesRepository>(),
                  employmentDetailsRepository:
                      context.read<EmploymentDetailsRepository>(),
                ),
              ),
              BlocProvider<LoanBloc>.value(
                value: LoanBloc(
                  loanRepository: context.read<LoanRepository>(),
                  loanScheduleRepository:
                      context.read<LoanScheduleRepository>(),
                  userRepository: context.read<UserRepository>(),
                  settingsRepository: context.read<SettingsRepository>(),
                  authenticationService: context.read<AuthenticationService>(),
                ),
              ),
            ],
            child: Builder(
              builder: (context) {
                return FutureBuilder(
                  builder: (context, snapshot) {
                    printd('app.dart: called on refresh');

                    if (snapshot.connectionState != ConnectionState.done) {
                      return Container();
                    }

                    context.read<AuthenticationBloc>().initialize();
                    context.read<SettingsBloc>().getSettings();
                    context.read<UserBloc>().getAllUsers();
                    context.read<LoanBloc>().initialize();

                    return MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      routerConfig: _rootRouter,
                      theme: ThemeData(
                        useMaterial3: true,
                        colorScheme: lightColorScheme,
                      ),
                      darkTheme: ThemeData(
                        useMaterial3: true,
                        colorScheme: darkColorScheme,
                      ),
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      // home: const MainScreen(),
                    );
                  },
                  future: Future.wait([
                    context.read<AuthenticationBloc>().initializeFuture(),
                    context.read<SettingsBloc>().initializeFuture(),
                  ]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
