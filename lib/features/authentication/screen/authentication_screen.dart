import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class AuthenticationScreen extends StatelessWidget {
  AuthenticationScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    final width = screenSize.width;
    final computedWidth = width * 0.88;
    final loginContainerWidth = width * 0.315;
    var appBarHeight = screenSize.height * 0.2;
    var cardRadius = 100.0;
    var cardPadding = 56.0;
    var buttonHeight = 72.0;
    var buttonPadding = 24.0;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    if (shortestSide < Constants.largeScreenSmallestSideBreakPoint) {
      cardRadius = 48;
      cardPadding = 32;
      buttonHeight = 56;
      buttonPadding = 8;
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
    }

    printd('size: ${MediaQuery.of(context).size}');
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.48),
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Container(
              width: computedWidth,
              margin: const EdgeInsets.only(bottom: 48),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Constants.defaultRadius,
              bottomRight: Constants.defaultRadius,
            ),
          ),
        ),
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          printd(state);
          if (state is LoginSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
            GoRouter.of(context).go('/loan-dashboard');
          } else if (state is LoginErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        child: Container(
          margin: EdgeInsets.only(top: loginContainerMarginTop),
          height: double.infinity,
          width: loginContainerWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
            borderRadius: BorderRadius.only(
              topRight: loginContainerRadius,
              bottomRight: loginContainerRadius,
            ),
          ),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraint) {
                var width = 520.0;
                var height = 600.0;
                Widget content = Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            label: Text('Email'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            label: Text('Password'),
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.go,
                          onFieldSubmitted: (value) {
                            authenticationBloc.login(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          },
                        ),
                        const SizedBox(
                          height: 72,
                        ),
                        SizedBox(
                          height: buttonHeight,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => authenticationBloc.login(
                              email: emailController.text,
                              password: passwordController.text,
                            ),
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(buttonPadding),
                                backgroundColor:
                                Theme.of(context).colorScheme.primary),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.apply(color: Colors.white),
                                ),
                                BlocBuilder<AuthenticationBloc,
                                    AuthenticationState>(
                                    builder: (context, state) {
                                      if (state is LoginLoadingState &&
                                          state.isLoading) {
                                        return Row(
                                          children: [
                                            const SizedBox(
                                              width: 16,
                                            ),
                                            const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          ],
                                        );
                                      }

                                      return Container();
                                    }),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );

                if (screenSize.shortestSide <
                    Constants.largeScreenSmallestSideBreakPoint) {
                  width = constraint.maxWidth * 0.8;
                  height = constraint.maxHeight * 0.8;
                  content = SingleChildScrollView(
                    child: content,
                  );
                }

                return SizedBox(
                  height: height,
                  width: width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardRadius)),
                    child: content,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
