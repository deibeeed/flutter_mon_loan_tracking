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
      incidentalFeeRateController.text = settings.incidentalFeeRate.toString();
      downpaymentRateController.text = settings.downPaymentRate.toString();
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
          if (loanBloc.selectedLot != null && loanBloc.settings != null) {
            final lot = loanBloc.selectedLot!;
            final settings = loanBloc.settings!;
            lotAreaController.text = lot.area.toString();

            final lotCategory = settings.lotCategories.firstWhereOrNull(
                (category) => category.key == lot.lotCategoryKey);

            if (lotCategory != null) {
              lotCategoryController.text = lotCategory.name;
              pricePerSqmController.text =
                  lotCategory.ratePerSquareMeter.toCurrency();
              tcpController.text =
                  (lot.area * lotCategory.ratePerSquareMeter).toCurrency();
              downpaymentController.text = loanBloc
                  .computeDownPaymentRate(
                  customDownpaymentRateStr: downpaymentRateController.text)
                  .toString();
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
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
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
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
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
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
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
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
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
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: lotAreaController,
                  enabled: false,
                  decoration: const InputDecoration(
                    label: Text('Lot Area (sqm)'),
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
                  controller: lotCategoryController,
                  enabled: false,
                  decoration: const InputDecoration(
                      label: Text('Lot category'),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
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
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: tcpController,
                  enabled: false,
                  decoration: const InputDecoration(
                    label: Text('Total contract price'),
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
                TextFormField(
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
                const SizedBox(
                  height: 32,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
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
                            keyboardType: const TextInputType.numberWithOptions(
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
                    Row(
                      children: [
                        for (var i = 0; i < loanBloc.discounts.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Chip(
                              padding: const EdgeInsets.only(
                                  left: 8, top: 8, bottom: 8, right: 16),
                              label: Text(
                                'Less: ${loanBloc.discounts[i].description}: ${loanBloc.discounts[i].discount.toCurrency()}',
                              ),
                              onDeleted: () =>
                                  loanBloc.removeDiscount(position: i),
                              deleteIcon: const Icon(Icons.cancel),
                            ),
                          )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
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
                const SizedBox(
                  height: 32,
                ),
                Text(
                  'Lot description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${' ' * 16}${loanBloc.selectedLot?.description ?? ''}',
                ),
                const SizedBox(
                  height: 32,
                ),
                ElevatedButton(
                  onPressed: () => loanBloc.calculateLoan(
                    downPayment: downpaymentController.text,
                    yearsToPay: loanDurationController.text,
                    date: Constants.defaultDateFormat.format(DateTime.now()),
                    incidentalFeeRate: incidentalFeeRateController.text,
                    loanInterestRate: interestRateController.text,
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
                    const Text('Lot area:'),
                    Text(loanBloc.selectedLot?.description ?? ''),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                category.key == lot.lotCategoryKey);

                        return Text(
                            '${lotCategory?.ratePerSquareMeter.toCurrency() ?? 0.toCurrency()} per sqm');
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total contract price:'),
                    Text(loanBloc.computeTCP().toCurrency()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Loan duration:'),
                    Text(
                        '${loanDurationController.text} years to pay (${loanBloc.yearsToMonths(years: loanDurationController.text)} mos.)'),
                  ],
                ),
                ...loanBloc.discounts
                    .map(
                      (discount) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Less: ${discount.description}:'),
                          Text(
                            discount.discount.toCurrency(isDeduction: true),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add: Incidental fee:'),
                    Text(loanBloc
                        .computeIncidentalFee(
                        customIncidentalFeeRateStr:
                        incidentalFeeRateController.text)
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Outstanding balance:'),
                    Text(loanBloc.outstandingBalance.toCurrency()),
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
                          var lot = loanBloc.selectedLot;

                          if (loan == null || lot == null) {
                            return;
                          }

                          PdfGenerator.generatePdf(
                            schedules: loanBloc.clientLoanSchedules,
                            loan: loan,
                            lot: lot,
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
                          isSmallScreen: true
                      ),
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
