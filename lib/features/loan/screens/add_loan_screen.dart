import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';

class AddLoanScreen extends StatelessWidget {
  const AddLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loanBloc = BlocProvider.of<LoanBloc>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: ListView(
        children: [
          TextFormField(
            decoration: InputDecoration(
                label: Text('Last name'), border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 32,
          ),
          TextFormField(
            decoration: InputDecoration(
                label: Text('First name'), border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text('Block No.'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
              SizedBox(
                width: 32,
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text('Lot no.'),
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
              SizedBox(
                width: 32,
              ),
              Expanded(
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    label: Text('Lot Area'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
              SizedBox(
                width: 32,
              ),
              Expanded(
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                      label: Text('Lot category'),
                      border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
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
              SizedBox(
                width: 32,
              ),
              Expanded(
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    label: Text('Total contract price'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
              SizedBox(
                width: 32,
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text('Loan duration (Years)'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
              SizedBox(
                width: 32,
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                      label: Text('Downpayment'),
                      border: OutlineInputBorder(),),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text('Discount'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                    ),
                    SizedBox(
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
                                  padding: EdgeInsets.only(right: 16),
                                  child: Chip(
                                    padding: const EdgeInsets.only(
                                        left: 8, top: 8, bottom: 8, right: 16),
                                    label: Text(
                                      'Less: ${loanBloc.discounts[i].toCurrency()}',
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
              SizedBox(
                width: 16,
              ),
              ElevatedButton(
                onPressed: loanBloc.calculateLoan,
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(24),
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: Text(
                  'Add discount',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.apply(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(
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
          Text(
            '${' ' * 16}this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. this text description is very loooooooongggg. ',
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: loanBloc.calculateLoan,
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(24),
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
          SizedBox(
            height: 32,
          ),
          Divider(
            thickness: 1.5,
          ),
          SizedBox(
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
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenSize.width * 0.2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Lot area:'),
                          Text(9000.toCurrency()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total contract price:'),
                          Text(1000000.toCurrency()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Loan duration:'),
                          Text('5 years to pay (60 mos.)'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.2,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Less: Downpayment:'),
                          Text(100000.toCurrency(isDeduction: true)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Less: Reservation fee:'),
                          Text(10000.toCurrency(isDeduction: true)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Add: Incidental fee:'),
                          Text(120000.toCurrency()),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly due:'),
                          Text(25000.toCurrency()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Divider(
            thickness: 1.5,
          ),
          SizedBox(
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
          SizedBox(
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
                  for (String name in Constants.loan_schedule_table_columns)
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
                                text: schedule.outstandingBalance.toCurrency(),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: defaultCellText(
                                text: schedule.monthlyAmortization.toCurrency(),
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
                        ],
                      ),
                    )
                    .toList(),
              );
            },
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => print('pressed'),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(24),
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: Text(
                    'Add loan',
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
