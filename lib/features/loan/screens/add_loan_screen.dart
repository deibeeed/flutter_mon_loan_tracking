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
                    label: Text('Loan interest rate'),
                    suffixText: '%',
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
                    label: Text('Incidental fee rate'),
                    suffixText: '%',
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
                    label: Text('Reservation fee'),
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
                      label: Text('Lot categories'),
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
                    ],
                  ),
                )
                    .toList()
              // rows: [
              //   DataRow(
              //     cells: [
              //       DataCell(
              //         defaultCellText(text: '2023-01-30'),
              //       ),
              //       DataCell(
              //         Center(
              //           child: defaultCellText(text: '₱ 100.00'),
              //         ),
              //       ),
              //       DataCell(
              //         Center(
              //           child: defaultCellText(text: '₱ 100.00'),
              //         ),
              //       ),
              //       DataCell(
              //         Center(
              //           child: defaultCellText(text: '₱ 100.00'),
              //         ),
              //       ),
              //       DataCell(
              //         Center(
              //           child: defaultCellText(text: '₱ 100.00'),
              //         ),
              //       ),
              //       DataCell(
              //         Center(
              //           child: defaultCellText(text: '₱ 100.00'),
              //         ),
              //       ),
              //     ],
              //   ),
              // ],
            );
          },),
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
