import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan_calculator/screens/loan_calculator_screen_small.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_mon_loan_tracking/widgets/pdf_generator.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  _LoanCalculatorScreenState() : super();

  final blockNoController = TextEditingController();
  final lotNoController = TextEditingController();
  final lotAreaController = TextEditingController();
  final lotCategoryController = TextEditingController();
  final pricePerSqmController = TextEditingController();
  final tcpController = TextEditingController();
  final loanDurationController = TextEditingController();
  final downpaymentController = TextEditingController();
  final discountController = TextEditingController();
  final discountDescriptionController = TextEditingController();
  final incidentalFeeRateController = TextEditingController();
  final downpaymentRateController = TextEditingController();
  final interestRateController = TextEditingController();
  final horizontalScrollController = ScrollController();
  final serviceFeeController = TextEditingController();
  final pagingController = PagingController<int, LoanSchedule>(firstPageKey: 0);
  var _downpaymentPopulated = false;

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
      incidentalFeeRateController.text = settings.incidentalFeeRate.toString();
      downpaymentRateController.text = settings.downPaymentRate.toString();
      interestRateController.text = settings.loanInterestRate.toString();
      serviceFeeController.text = settings.serviceFee.toString();
    }
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
          if (loanBloc.selectedLot != null && loanBloc.settings != null) {
            final lot = loanBloc.selectedLot!;
            final settings = loanBloc.settings!;
            lotAreaController.text = lot.area.toString();

            final dpRate = downpaymentRateController.text;
            downpaymentController.text = loanBloc
                .computeDownPaymentRate(
                  customDownpaymentRateStr: dpRate.isNotEmpty ? dpRate : null,
                  withCustomTCP: tcpController.text.isNotEmpty
                      ? Constants.defaultCurrencyFormat
                          .parse(tcpController.text)
                      : null,
                )
                .toCurrency();

            if (!loanBloc.withCustomTCP) {
              final lotCategory = settings.lotCategories.firstWhereOrNull(
                  (category) => category.key == lot.lotCategoryKey);

              if (lotCategory != null) {
                lotCategoryController.text = lotCategory.name;
                pricePerSqmController.text =
                    lotCategory.ratePerSquareMeter.toCurrency();

                if (!loanBloc.withCustomTCP) {
                  tcpController.text =
                      (lot.area * lotCategory.ratePerSquareMeter).toCurrency();
                } else {
                  tcpController.text = Constants.defaultCurrencyFormat
                      .parse(tcpController.text)
                      .toCurrency();
                }
              }
            }
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
        body: ListView(
          children: [
            SizedBox(
              height: 8,
            ),
            BlocBuilder<LoanBloc, LoanState>(
                buildWhen: (previous, current) => current is LoanSuccessState,
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
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
                          onChanged: (value) {
                            if (blockNoController.text.isNotEmpty &&
                                lotNoController.text.isNotEmpty) {
                              loanBloc.setBlockAndLotNo(
                                type: 'blockNo',
                                no: blockNoController.text,
                              );
                              loanBloc.setBlockAndLotNo(
                                type: 'lotNo',
                                no: lotNoController.text,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: downpaymentRateController,
                          decoration: const InputDecoration(
                            label: Text('Downpayment rate'),
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                          onChanged: (value) {
                            printd('downpayment changedd');
                            if (blockNoController.text.isNotEmpty &&
                                lotNoController.text.isNotEmpty) {
                              printd('condition ok');
                              loanBloc.setBlockAndLotNo(
                                type: 'blockNo',
                                no: blockNoController.text,
                              );
                              loanBloc.setBlockAndLotNo(
                                type: 'lotNo',
                                no: lotNoController.text,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: incidentalFeeRateController,
                          decoration: const InputDecoration(
                            label: Text('Incidental fee rate'),
                            suffixText: '%',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                          onChanged: (value) {
                            if (blockNoController.text.isNotEmpty &&
                                lotNoController.text.isNotEmpty) {
                              loanBloc.setBlockAndLotNo(
                                type: 'blockNo',
                                no: blockNoController.text,
                              );
                              loanBloc.setBlockAndLotNo(
                                type: 'lotNo',
                                no: lotNoController.text,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: serviceFeeController,
                          decoration: const InputDecoration(
                            label: Text('Service fee rate'),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                          onChanged: (value) {
                            if (blockNoController.text.isNotEmpty &&
                                lotNoController.text.isNotEmpty) {
                              loanBloc.setBlockAndLotNo(
                                type: 'blockNo',
                                no: blockNoController.text,
                              );
                              loanBloc.setBlockAndLotNo(
                                type: 'lotNo',
                                no: lotNoController.text,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }),
            const SizedBox(
              height: 32,
            ),
            BlocBuilder<LoanBloc, LoanState>(
                buildWhen: (previous, current) => current is LoanSuccessState,
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: blockNoController,
                          decoration: const InputDecoration(
                            label: Text('Block No.'),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                          onChanged: (value) => loanBloc.setBlockAndLotNo(
                            type: 'blockNo',
                            no: value,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: lotNoController,
                          decoration: const InputDecoration(
                            label: Text('Lot no.'),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                          onChanged: (value) => loanBloc.setBlockAndLotNo(
                            type: 'lotNo',
                            no: value,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: lotAreaController,
                          enabled: false,
                          decoration: const InputDecoration(
                            label: Text('Lot Area (sqm)'),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
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
                          controller: lotCategoryController,
                          enabled: false,
                          decoration: const InputDecoration(
                              label: Text('Lot category'),
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  );
                }),
            const SizedBox(
              height: 32,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pricePerSqmController,
                    enabled: false,
                    decoration: const InputDecoration(
                      label: Text('Price / sqm'),
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
                      downpaymentController.text = loanBloc
                          .computeDownPaymentRate(
                            withCustomTCP: val.isNotEmpty
                                ? Constants.defaultCurrencyFormat
                                    .parse(tcpController.text)
                                : null,
                          )
                          .toCurrency();
                    },
                  ),
                ),
                const SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: TextFormField(
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
                ),
                const SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: TextFormField(
                    controller: downpaymentController,
                    decoration: const InputDecoration(
                      label: Text('Downpayment'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: discountController,
                              decoration: const InputDecoration(
                                label: Text('Discount'),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[0-9.,]'),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 32,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: discountDescriptionController,
                              decoration: const InputDecoration(
                                label: Text('Description'),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previous, current) =>
                              current is LoanSuccessState,
                          builder: (context, state) {
                            return Row(
                              children: [
                                for (var i = 0;
                                    i < loanBloc.discounts.length;
                                    i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Chip(
                                      padding: const EdgeInsets.only(
                                          left: 8,
                                          top: 8,
                                          bottom: 8,
                                          right: 16),
                                      label: Text(
                                        'Less: ${loanBloc.discounts[i].description}: ${loanBloc.discounts[i].discount.toCurrency()}',
                                      ),
                                      onDeleted: () =>
                                          loanBloc.removeDiscount(position: i),
                                      deleteIcon: const Icon(Icons.cancel),
                                    ),
                                  )
                              ],
                            );
                          }),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      loanBloc.addDiscount(
                        discount: discountController.text,
                        description: discountDescriptionController.text,
                      );
                      discountController.text = '';
                      discountDescriptionController.text = '';
                    },
                    style: ElevatedButton.styleFrom(
                        padding: buttonPadding,
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      'Add discount',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.apply(color: Colors.white),
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
                Text(
                  'Lot description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            BlocBuilder<LoanBloc, LoanState>(
              buildWhen: (previous, current) => current is LoanSuccessState,
              builder: (context, state) {
                String? description = '';

                if (loanBloc.selectedLot != null) {
                  description = loanBloc.selectedLot?.description;
                }

                return Text(
                  '${' ' * 16}$description',
                );
              },
            ),
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => loanBloc.calculateLoan(
                    downPayment: downpaymentController.text,
                    yearsToPay: loanDurationController.text,
                    date: Constants.defaultDateFormat.format(DateTime.now()),
                    incidentalFeeRate: incidentalFeeRateController.text,
                    loanInterestRate: interestRateController.text,
                    serviceFeeRate: serviceFeeController.text,
                    totalContractPrice: tcpController.text,
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
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: screenSize.width * 0.2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Lot area:'),
                                  Text(loanBloc.selectedLot?.area.withUnit() ??
                                      ''),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Price per sqm:'),
                                  Builder(
                                    builder: (context) {
                                      if (loanBloc.selectedLot == null ||
                                          loanBloc.settings == null) {
                                        return Container();
                                      }

                                      final lot = loanBloc.selectedLot!;
                                      final settings = loanBloc.settings!;
                                      final lotCategory = settings.lotCategories
                                          .firstWhereOrNull((category) =>
                                              category.key ==
                                              lot.lotCategoryKey);

                                      return Text(
                                          '${lotCategory?.ratePerSquareMeter.toCurrency() ?? 0.toCurrency()} per sqm');
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total contract price:'),
                                  Text(loanBloc
                                      .computeTCP(
                                        withCustomTCP: tcpController
                                                .text.isNotEmpty
                                            ? Constants.defaultCurrencyFormat
                                                .parse(tcpController.text)
                                            : null,
                                      )
                                      .toCurrency()),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Loan duration:'),
                                  Text(
                                      '${loanDurationController.text} years to pay (${loanBloc.yearsToMonths(years: loanDurationController.text)} mos.)'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: screenSize.width * 0.2,
                          child: Column(
                            children: [
                              ...loanBloc.discounts
                                  .map(
                                    (discount) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Less: ${discount.description}:'),
                                        Text(
                                          discount.discount
                                              .toCurrency(isDeduction: true),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Add: Incidental fee:'),
                                  Text(loanBloc
                                      .computeIncidentalFee(
                                        customIncidentalFeeRateStr:
                                            incidentalFeeRateController.text,
                                        withCustomTCP: tcpController
                                                .text.isNotEmpty
                                            ? Constants.defaultCurrencyFormat
                                                .parse(tcpController.text)
                                            : null,
                                      )
                                      .toCurrency()),
                                ],
                              ),
                              if (serviceFeeController.text.isNotEmpty ||
                                  serviceFeeController.text == '0')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Add: Service fee:'),
                                    Text(num.parse(serviceFeeController.text)
                                        .toCurrency()),
                                  ],
                                ),
                              if (loanBloc.getVatAmount() != null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Add: VAT:'),
                                    Text(
                                      loanBloc.getVatAmount()!.toCurrency(),
                                    ),
                                  ],
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Outstanding balance:'),
                                  Text(
                                      loanBloc.outstandingBalance.toCurrency()),
                                ],
                              ),
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
                      var lot = loanBloc.selectedLot;

                      if (loan == null || lot == null) {
                        return;
                      }

                      PdfGenerator.generatePdf(
                        schedules: loanBloc.clientLoanSchedules,
                        loan: loan,
                        lot: lot,
                        showServiceFee: true,
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
    );
  }
}
