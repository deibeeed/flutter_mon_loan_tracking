import 'dart:math';

import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class AuthenticationScreen extends StatefulWidget {
  AuthenticationScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    final screenSize = MediaQuery
        .of(context)
        .size;
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
    var isMobileScreen = false;

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      cardRadius = 48;
      cardPadding = 32;
      buttonHeight = 56;
      buttonPadding = 8;
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
    }

    if (shortestSide <= Constants.smallScreenShortestSideBreakPoint) {
      isMobileScreen = true;
    }

    printd('size: ${MediaQuery
        .of(context)
        .size}');
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor:
          Theme
              .of(context)
              .colorScheme
              .primary
              .withOpacity(0.48),
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
            if (state.message.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }

            if (state.user != null) {
              GoRouter.of(context).go('/loan-dashboard');
            }
          } else if (state is LoginErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        child: authenticationBloc.isLoggedIn()
            ? Container()
            : Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  top: loginContainerMarginTop,
                  bottom: !isMobileScreen ? 0 : loginContainerMarginTop,
                  left: !isMobileScreen ? 0 : 16,
                  right: !isMobileScreen ? 0 : 16,
                ),
                height: double.infinity,
                width:
                !isMobileScreen ? loginContainerWidth : double.infinity,
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .tertiary
                      .withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    topRight: loginContainerRadius,
                    bottomRight: loginContainerRadius,
                    topLeft: !isMobileScreen
                        ? Radius.zero
                        : loginContainerRadius,
                    bottomLeft: !isMobileScreen
                        ? Radius.zero
                        : loginContainerRadius,
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
                              Autocomplete(
                                optionsBuilder: (value) =>
                                    authenticationBloc.emails.where(
                                          (email) =>
                                          email
                                              .toLowerCase()
                                              .contains(value.text),
                                    ),
                                displayStringForOption: (value) => value,
                                onSelected: (value) {
                                  emailController.text = value;
                                  passwordController.text = value;
                                  authenticationBloc.selectEmail();
                                },
                                fieldViewBuilder: (context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted) {
                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    onFieldSubmitted: (value) =>
                                        onFieldSubmitted(),
                                    decoration: const InputDecoration(
                                      label: Text('Email'),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      emailController.text = value;
                                      passwordController.text = value;
                                    },
                                  );
                                },
                              ),
                              // TextFormField(
                              //   controller: emailController,
                              //   decoration: const InputDecoration(
                              //     label: Text('Email'),
                              //     border: OutlineInputBorder(),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 32,
                              ),
                              BlocBuilder<AuthenticationBloc,
                                  AuthenticationState>(
                                  buildWhen: (previous,
                                      current) => current is UiEmitState,
                                  builder: (context, state) {
                                    return TextFormField(
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
                                    );
                                  }),
                              const SizedBox(
                                height: 72,
                              ),
                              SizedBox(
                                height: buttonHeight,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      authenticationBloc.login(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      ),
                                  style: ElevatedButton.styleFrom(
                                      padding:
                                      EdgeInsets.all(buttonPadding),
                                      backgroundColor: Theme
                                          .of(context)
                                          .colorScheme
                                          .primary),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Login',
                                        style: Theme
                                            .of(context)
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
                                                children: const [
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                  CircularProgressIndicator(
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
                          Constants.largeScreenShortestSideBreakPoint) {
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
                              borderRadius:
                              BorderRadius.circular(cardRadius)),
                          child: content,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (!isMobileScreen) ...[
              const SizedBox(
                width: 32,
              ),
              BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state) {
                    return Expanded(
                      child: authenticationBloc.backgroundDownloadUrl == null
                          ? Container()
                          : Container(
                        margin: EdgeInsets.only(
                            top: loginContainerMarginTop,
                            right: loginContainerMarginTop,
                            bottom: 32),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                              BorderRadius.all(Radius.circular(64)),
                              child: Image.asset(
                                'assets/images/login_bg.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            DropShadow(
                              offset: Offset(4, 4),
                              color: Colors.white,
                              spread: 0,
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ]
          ],
        ),
      ),
    );
  }
}
