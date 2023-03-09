import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class AddUserScreen extends StatelessWidget {
  AddUserScreen({super.key});

  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final civilStatusController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final birthDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    final width = screenSize.width;
    final computedWidth = width * 0.88;
    var appBarHeight = screenSize.height * 0.16;
    var appBarBottomPadding = 48.0;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var titleTextStyle = Theme.of(context).textTheme.displaySmall;
    var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
    var avatarSize = 56.0;

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      appBarBottomPadding = 24;
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      titleTextStyle = Theme.of(context).textTheme.headlineMedium;
      avatarTextStyle = Theme.of(context).textTheme.titleSmall;
      avatarSize = 48;
    }

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoadingState) {
          if (state.isLoading) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const AlertDialog(
                    content: SizedBox(
                      width: 56,
                      height: 56,
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
        } else if (state is UserSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        } else if (state is UserErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is CloseScreenState) {
          GoRouter.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: !isMobile()
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight),
                child: AppBar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.48),
                  leading: !isMobile()
                      ? Container()
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => GoRouter.of(context).pop(),
                        ),
                  bottom: PreferredSize(
                    preferredSize: Size.zero,
                    child: Container(
                      width: computedWidth,
                      margin: EdgeInsets.only(bottom: appBarBottomPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add user',
                            style: titleTextStyle?.apply(color: Colors.white),
                          ),
                          SizedBox(
                            width: avatarSize,
                            height: avatarSize,
                            child: InkWell(
                              onTap: () {
                                final user =
                                    context.read<UserBloc>().getLoggedInUser();
                                if (user != null) {
                                  GoRouter.of(context)
                                      .push('/users/${user.id}');
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    context
                                            .read<UserBloc>()
                                            .getLoggedInUser()
                                            ?.initials ??
                                        'No',
                                    style: avatarTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: loginContainerRadius,
                      bottomRight: loginContainerRadius,
                    ),
                  ),
                ),
              ),
        body: shortestSide <= Constants.smallScreenShortestSideBreakPoint
            ? _buildSmallScreenBody(context: context)
            : _buildLargeScreenBody(context: context),
      ),
    );
  }

  Widget _buildSmallScreenBody({required BuildContext context}) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                var type = UserType.customer;

                if (state is SelectedUserTypeState) {
                  type = state.type;
                }

                return DropdownButton<UserType>(
                  value: type,
                  items: UserType.values.map((type) {
                    return DropdownMenuItem<UserType>(
                      value: type,
                      child: Text(type.value),
                    );
                  }).toList(),
                  onChanged: (value) => userBloc.selectUserType(type: value),
                );
              },
            ),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(
                  label: Text('Last name'), border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(
                  label: Text('First name'), border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              controller: birthDateController,
              decoration: const InputDecoration(
                label: Text('Birthdate'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              controller: civilStatusController,
              decoration: const InputDecoration(
                label: Text('Civil status'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              controller: mobileNumberController,
              decoration: const InputDecoration(
                label: Text('Mobile number'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
            ),
            const SizedBox(
              height: 32,
            ),
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
            ),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Confirm password'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => userBloc.addUser(
                        lastName: lastNameController.text,
                        firstName: firstNameController.text,
                        birthDate: birthDateController.text,
                        civilStatus: civilStatusController.text,
                        mobileNumber: mobileNumberController.text,
                        email: emailController.text,
                        password: passwordController.text,
                        confirmPassword: confirmPasswordController.text),
                    style: ElevatedButton.styleFrom(
                        padding: buttonPadding,
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      'Add User',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.apply(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenBody({required BuildContext context}) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User type'),
          const SizedBox(
            height: 8,
          ),
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              var type = UserType.customer;

              if (state is SelectedUserTypeState) {
                type = state.type;
              }

              return SizedBox(
                width: double.infinity,
                child: DropdownButton<UserType>(
                  value: type,
                  items: UserType.values.map((type) {
                    return DropdownMenuItem<UserType>(
                      value: type,
                      child: Text(type.value),
                    );
                  }).toList(),
                  onChanged: (value) => userBloc.selectUserType(type: value),
                ),
              );
            },
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(
                label: Text('Last name'), border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(
                label: Text('First name'), border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: birthDateController,
                  decoration: const InputDecoration(
                    label: Text('Birthdate'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                width: 32,
              ),
              Expanded(
                child: TextFormField(
                  controller: civilStatusController,
                  decoration: const InputDecoration(
                    label: Text('Civil status'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                width: 32,
              ),
              Expanded(
                child: TextFormField(
                  controller: mobileNumberController,
                  decoration: const InputDecoration(
                    label: Text('Mobile number'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    label: Text('Email'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // const SizedBox(
              //   width: 32,
              // ),
              // Expanded(
              //   child: TextFormField(
              //     controller: passwordController,
              //     obscureText: true,
              //     decoration: const InputDecoration(
              //       label: Text('Password'),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   width: 32,
              // ),
              // Expanded(
              //   child: TextFormField(
              //     controller: confirmPasswordController,
              //     obscureText: true,
              //     decoration: const InputDecoration(
              //       label: Text('Confirm password'),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => userBloc.addUser(
                      lastName: lastNameController.text,
                      firstName: firstNameController.text,
                      birthDate: birthDateController.text,
                      civilStatus: civilStatusController.text,
                      mobileNumber: mobileNumberController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      confirmPassword: confirmPasswordController.text),
                  style: ElevatedButton.styleFrom(
                      padding: buttonPadding,
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: Text(
                    'Add User',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.apply(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
