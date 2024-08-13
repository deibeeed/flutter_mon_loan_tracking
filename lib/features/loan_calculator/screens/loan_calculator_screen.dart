import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan_calculator/screens/loan_calculator_screen_small.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_mon_loan_tracking/widgets/pdf_generator.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  _LoanCalculatorScreenState() : super();

  final _formKey =
      GlobalKey<FormBuilderState>(debugLabel: 'loan_calculator_screen');
  final horizontalScrollController = ScrollController();
  final pagingController = PagingController<int, LoanSchedule>(firstPageKey: 0);

  @override
  void deactivate() {
    context.read<LoanBloc>().reset();
    printd('deactivated');
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    context.read<LoanBloc>().getSettings();
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserBloc>().getAllUsers();
    final loanBloc = BlocProvider.of<LoanBloc>(context)..getSettings();
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;

    if (shortestSide <= Constants.smallScreenShortestSideBreakPoint) {
      return const LoanCalculatorScreenSmall();
    }

    var buttonPadding = const EdgeInsets.all(24);
    var isLargeScreenBreakpoint = false;

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      isLargeScreenBreakpoint = true;
    }

    return BlocListener<LoanBloc, LoanState>(
      listener: (context, state) {
        if (state is LoanSuccessState) {
          if (loanBloc.settings != null) {
            final settings = loanBloc.settings!;
          }

          pagingController.value = PagingState(
            itemList: loanBloc.clientLoanSchedules,
          );
        } else if (state is LoanErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is LoanLoadingState) {
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
        } else if (state is CloseAddLoanState) {
          GoRouter.of(context).pop();
        }
      },
      child: Scaffold(
        body: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              Gap(8),
              FormBuilderTextField(
                name: 'amount',
                decoration: const InputDecoration(
                  label: Text('Loan amount'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[0-9]*[.]?[0-9]*'),
                  ),
                ],
                valueTransformer: (amt) {
                  if (amt == null) {
                    return null;
                  }

                  return double.parse(amt);
                },
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(
                      errorText: 'Please enter loan amount',
                    ),
                  ],
                ),
              ),
              const Gap(16),
              FormBuilderTextField(
                name: 'term',
                decoration: const InputDecoration(
                  label: Text('Term (In months)'),
                  border: OutlineInputBorder(),
                ),
                valueTransformer: (term) {
                  if (term == null) {
                    return null;
                  }

                  print('transformer called');

                  return int.parse(term);
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(
                      errorText: 'Please enter term',
                    ),
                  ],
                ),
              ),
              const Gap(16),
              FormBuilderTextField(
                name: 'interest_rate',
                initialValue: context
                    .read<LoanBloc>()
                    .settings
                    ?.loanInterestRate
                    .toString(),
                decoration: const InputDecoration(
                  label: Text('Monthly interest rate'),
                  border: OutlineInputBorder(),
                ),
                valueTransformer: (term) {
                  if (term == null) {
                    return null;
                  }

                  print('transformer called');

                  return double.parse(term);
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(
                      errorText: 'Please enter interest rate',
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        loanBloc.calculateLoan(
                          monthsToPay:
                              _formKey.currentState!.value['term'] as int,
                          date: DateTime.now(),
                          interestRate: _formKey
                              .currentState!.value['interest_rate'] as double,
                          amount:
                              _formKey.currentState!.value['amount'] as double,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        padding: buttonPadding,
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      'Calculate loan',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.apply(color: Colors.white),
                    ),
                  )
                ],
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
                    'Computation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              BlocBuilder<LoanBloc, LoanState>(
                  buildWhen: (previous, current) => current is LoanSuccessState,
                  builder: (context, state) {
                    final term =
                        _formKey.currentState!.instantValue['term'] ?? 0;
                    var amount = _formKey.currentState!.instantValue['amount'];

                    if (amount != null) {
                      if (amount.runtimeType == double) {
                        amount = (amount as double).toCurrency();
                      } else if (amount.runtimeType == int) {
                        amount = (amount as int).toCurrency();
                      } else if (amount.runtimeType == String) {
                        amount = double.parse(amount as String).toCurrency();
                      }
                    } else {
                      amount = 0.0.toCurrency();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Loan principal:'),
                                    Text('$amount'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Term (in months):'),
                                    Text('$term months'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: screenSize.width * 0.2,
                            child: Column(
                              children: [
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Monthly due:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.apply(
                                            fontWeightDelta: 2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary
                                                .withOpacity(0.8),
                                          ),
                                    ),
                                    Text(
                                      loanBloc.monthlyAmortization.toCurrency(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.apply(
                                            fontWeightDelta: 2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary
                                                .withOpacity(0.8),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Loan schedule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      var loan = loanBloc.selectedLoan;

                      if (loan == null) {
                        return;
                      }

                      PdfGenerator.generatePdf(
                        schedules: loanBloc.clientLoanSchedules,
                        loan: loan,
                      );
                    },
                    child: Text(
                      'Print',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                        padding: EdgeInsets.all(16)),
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
                  if (!isLargeScreenBreakpoint) {
                    return buildDashboardTable(
                        context: context,
                        loanBloc: loanBloc,
                        pagingController: pagingController);
                  }

                  return Scrollbar(
                    controller: horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: buildDashboardTable(
                          context: context,
                          loanBloc: loanBloc,
                          pagingController: pagingController,
                          finiteSize: loanBloc.clientLoanSchedules.isNotEmpty),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
