import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_mon_loan_tracking/widgets/pdf_generator.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LoanCalculatorScreenSmall extends StatefulWidget {
  const LoanCalculatorScreenSmall({super.key});

  @override
  State<StatefulWidget> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreenSmall> {
  _LoanCalculatorScreenState() : super();

  final tcpController = TextEditingController();
  final loanDurationController = TextEditingController();
  final interestRateController = TextEditingController();
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
    final settings = context.read<LoanBloc>().settings;

    if (settings != null) {
      interestRateController.text = settings.loanInterestRate.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanBloc = BlocProvider.of<LoanBloc>(context)..getSettings();
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);
    var isLargeScreenBreakpoint = false;

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      isLargeScreenBreakpoint = true;
    }

    return BlocListener<LoanBloc, LoanState>(
      listener: (context, state) {
        if (state is LoanSuccessState) {

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
        body: BlocBuilder<LoanBloc, LoanState>(
          buildWhen: (previous, current) => current is LoanSuccessState,
          builder: (context, state) {
            return ListView(
              children: [
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: interestRateController,
                  decoration: const InputDecoration(
                    label: Text('Interest rate'),
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: tcpController,
                  decoration: const InputDecoration(
                    label: Text('Total contract price'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^[0-9]*[.]?[0-9]*'),
                    ),
                  ],
                  onChanged: (val) {

                  },
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: loanDurationController,
                  decoration: const InputDecoration(
                    label: Text('Loan duration (Years)'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                ElevatedButton(
                  onPressed: () => loanBloc.calculateLoan(
                    monthsToPay: loanDurationController.text,
                    date: Constants.defaultDateFormat.format(DateTime.now()),
                    loanInterestRate: interestRateController.text,
                    amount: tcpController.text,
                  ),
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
                Text(
                  'Computation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Loan duration:'),
                    Text(
                        '${loanDurationController.text} years to pay (${loanBloc.yearsToMonths(years: loanDurationController.text)} mos.)'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly due:',
                      style: Theme.of(context).textTheme.titleLarge?.apply(
                            fontWeightDelta: 2,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.8),
                          ),
                    ),
                    Text(
                      loanBloc.monthlyAmortization.toCurrency(),
                      style: Theme.of(context).textTheme.titleLarge?.apply(
                            fontWeightDelta: 2,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.8),
                          ),
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Loan schedule',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
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
                          style: Theme.of(context).textTheme.labelLarge,
                        ))
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
                        pagingController: pagingController,
                        isSmallScreen: true,
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: buildDashboardTable(
                          context: context,
                          loanBloc: loanBloc,
                          pagingController: pagingController,
                          isSmallScreen: true),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
