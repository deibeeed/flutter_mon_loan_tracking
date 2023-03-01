import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/main/screens/main_mobile_screen.dart';
import 'package:flutter_mon_loan_tracking/features/main/screens/main_web_screen.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

/// the container screen that contains all screens after login and splash
class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    Widget child = MainLargeScreen(content: content);

    if (shortestSide <= Constants.smallScreenShortestSideBreakPoint) {
      child = MainSmallScreen(content: content);
    }
    
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is LogoutSuccessState) {
          GoRouter.of(context).go('/login');
        } else if (state is LoginLoadingState) {
          if (state.isLoading) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const AlertDialog(
                    content: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(),
                    ),
                  );
                });
          } else {
            try {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            } catch (err) {
              printd(err);
            }
          }
        } else if (state is LoginErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: child,
    );
  }
}
