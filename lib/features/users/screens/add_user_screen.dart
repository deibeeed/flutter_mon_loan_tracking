import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

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

    if (shortestSide < Constants.largeScreenSmallestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
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
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
              ),
            );
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: [
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
                const SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text('Password'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text('Confirm password'),
                      border: OutlineInputBorder(),
                    ),
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
}
