import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/splash/bloc/splash_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
      return Center(
        child: BlocListener<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashGoToState) {
              GoRouter.of(context).go(state.goto);
            }
          },
          child: Text('splash screen here'),
        ),
      );
  }

}