import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:go_router/go_router.dart';

class UserDetailsScreen extends StatefulWidget {
  UserDetailsScreen({super.key});

  // NOTE: userId is required
  String? userId;

  @override
  State<StatefulWidget> createState() {
    return _UserDetailsScreenState();
  }
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final civilStatusController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final birthDateController = TextEditingController();

  @override
  void deactivate() {
    final menuItemLast = Constants.menuItems.last;

    if (menuItemLast.isDynamic) {
      Constants.menuItems.removeLast();
    }

    context.read<UserBloc>().reset();
    context.read<LoanBloc>().reset();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    final loanBloc = BlocProvider.of<LoanBloc>(context)
      ..getAllUsers()
      ..getAllLots()
      ..getAllLoans(clearList: true, clientId: widget.userId);

    final userBloc = BlocProvider.of<UserBloc>(context);

    if (widget.userId != null) {
      userBloc.selectUser(userId: widget.userId!);
    }

    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
    }

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserSuccessState) {
          if (userBloc.selectedUser != null) {
            final user = userBloc.selectedUser!;
            lastNameController.text = user.lastName;
            firstNameController.text = user.firstName;
            mobileNumberController.text = user.mobileNumber;
            emailController.text = user.email;
            civilStatusController.text = user.civilStatus.value;
            birthDateController.text = user.birthDate;
          }
        } else if (state is UserErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is UserLoadingState) {
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
        }
      },
      child: Scaffold(
        body: ListView(
          children: [
            const SizedBox(
              height: 16,
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
                const SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      label: Text('Email'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            Visibility(
              visible: _shouldShowUpdateButton(),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => userBloc.updateUser(
                        lastName: lastNameController.text,
                        firstName: firstNameController.text,
                        birthDate: birthDateController.text,
                        civilStatus: civilStatusController.text,
                        mobileNumber: mobileNumberController.text,
                        email: emailController.text,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: buttonPadding,
                          backgroundColor:
                          Theme.of(context).colorScheme.primary),
                      child: Text(
                        'Update profile',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.apply(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 32,),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: authenticationBloc.logout,
                      style: ElevatedButton.styleFrom(
                          padding: buttonPadding,
                          backgroundColor:
                          Theme.of(context).colorScheme.error),
                      child: Text(
                        'Logout',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.apply(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            const Divider(
              thickness: 1.5,
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text(
                  'Purchased lots',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Text('Some purchased lots here ???'),
            const SizedBox(
              height: 32,
            ),
            const Divider(
              thickness: 1.5,
            ),
            const SizedBox(
              height: 32,
            ),
            Row(
              children: [
                Text(
                  'Loan schedule',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            BlocBuilder<LoanBloc, LoanState>(
              buildWhen: (previous, current) {
                return current is LoanSuccessState;
              },
              builder: (context, state) {
                return DataTable(
                  dataRowHeight: 72,
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.32),
                  ),
                  columns: [
                    for (String name
                        in Constants.user_loan_schedule_table_columns)
                      DataColumn(
                          label: Text(
                        name.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.apply(
                              fontWeightDelta: 3,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ))
                  ],
                  rows: loanBloc.clientLoanSchedules
                      .map(
                        (schedule) => DataRow(
                          cells: [
                            DataCell(
                              defaultCellText(
                                text: Constants.defaultDateFormat.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    schedule.date.toInt(),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: defaultCellText(
                                  text:
                                      schedule.outstandingBalance.toCurrency(),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: defaultCellText(
                                  text:
                                      schedule.monthlyAmortization.toCurrency(),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: defaultCellText(
                                  text: schedule.principalPayment.toCurrency(),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: defaultCellText(
                                  text: schedule.interestPayment.toCurrency(),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: defaultCellText(
                                  text: schedule.incidentalFee.toCurrency(),
                                ),
                              ),
                            ),
                            DataCell(
                              paymentStatusWidget(
                                context: context,
                                schedule: schedule,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(
              height: 32,
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowUpdateButton() {
    final userBloc = BlocProvider.of<UserBloc>(context);

    if (widget.userId != null && userBloc.getLoggedInUser() != null) {
      return widget.userId == userBloc.getLoggedInUser()!.id;
    }

    return false;
  }
}
