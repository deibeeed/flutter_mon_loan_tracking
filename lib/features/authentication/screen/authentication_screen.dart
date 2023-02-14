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
    final width = MediaQuery.of(context).size.width;
    final computedWidth = width * 0.88;
    final loginContainerWidth = width * 0.315;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(220),
        child: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.48),
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Container(
              width: computedWidth,
              margin: const EdgeInsets.only(bottom: 48),
              // child: BlocBuilder<MenuSelectionCubit, MenuSelectionState>(
              //   builder: (context, state) {
              //     var menuItemName = Constants.menuItems[0].name;
              //     if (state is MenuPageSelected) {
              //       menuItemName = Constants.menuItems[state.page].name;
              //     }
              //
              //     return Text(
              //       menuItemName,
              //       style: Theme.of(context)
              //           .textTheme
              //           .displaySmall
              //           ?.apply(color: Colors.white),
              //     );
              //   },
              // ),
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
          margin: const EdgeInsets.only(top: 64),
          height: double.infinity,
          width: loginContainerWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topRight: Constants.defaultRadius,
              bottomRight: Constants.defaultRadius,
            ),
          ),
          child: Center(
            child: SizedBox(
              height: 600,
              width: 600,
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  child: Padding(
                    padding: EdgeInsets.all(56),
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
                          height: 72,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => authenticationBloc.login(
                              email: emailController.text,
                              password: passwordController.text,
                            ),
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(24),
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
                                BlocBuilder<AuthenticationBloc, AuthenticationState>(builder: (context, state) {
                                  if (state is LoginLoadingState && state.isLoading) {
                                    return Row(
                                      children: [
                                        const SizedBox(width: 16,),
                                        CircularProgressIndicator(color: Colors.white,)
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
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
