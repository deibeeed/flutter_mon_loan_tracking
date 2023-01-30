import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/general_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class LoanDashboardScreen extends StatelessWidget {
  const LoanDashboardScreen({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0,
        style: BorderStyle.none,
      ),
    );
    final generalFilterCubit = BlocProvider.of<GeneralFilterSelectionCubit>(
      context,
    );
    const defaultTableTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<GeneralFilterSelectionCubit, GeneralFilterSelectionState>(
            builder: (context, state) {
              var position = 0;

              if (state is FilterSelectedState) {
                position = state.position;
              }

              return Row(
                children: [
                  for (var i = 0;
                      i < Constants.loan_dashboard_general_filters.length;
                      i++)
                    Column(
                      children: [
                        TextButton(
                          onPressed: () =>
                              generalFilterCubit.select(position: i),
                          child: Text(
                            Constants.loan_dashboard_general_filters[i],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.apply(
                                    fontSizeDelta: 2,
                                    fontWeightDelta: 2,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                        ),
                        Visibility(
                            visible: position == i,
                            child: Container(
                              height: 2,
                              width: 56,
                              color: Theme.of(context).colorScheme.secondary,
                            ))
                      ],
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              height: 2,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: Card(
              color: Colors.white,
              shadowColor: Colors.black,
              elevation: 16,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, top: 24, bottom: 24),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => printd('hello'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(22),
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.8),
                            side: BorderSide(
                              width: 1.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.filter_alt_rounded),
                              Text(
                                'FILTER',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        SizedBox(
                          width: screenSize.width * 0.3,
                          child: TextFormField(
                            // style: TextStyle(fontSize: 16, ),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 32, right: 32, top: 20, bottom: 20),
                                label:
                                    const Text('Search users by name or email'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                border: defaultBorder,
                                enabledBorder: defaultBorder,
                                focusedBorder: defaultBorder),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox.expand(
                      child: DataTable(
                        dataRowHeight: 72,
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.32),
                        ),
                        columns: [
                          for (String name
                              in Constants.loan_dashboard_table_columns)
                            DataColumn(
                                label: Text(
                              name.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.apply(
                                    fontWeightDelta: 3,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ))
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    defaultCellText(text: 'David Andrew Francis Duldulao'),
                                    Text('dafduldulao@gmail.com')
                                  ],
                                ),
                              ),
                              DataCell(defaultCellText(text: 'Blk 1 Lot 1'),),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Chip(
                                      label: Text(
                                        'Paid',
                                        style: TextStyle(
                                            color: Color(0xff007F00),
                                            fontWeight: FontWeight.w600),
                                      ),
                                      backgroundColor: Color(0xffCDFFCD),
                                      avatar: Icon(
                                        Icons.fiber_manual_record_rounded,
                                        color: Color(0xff007F00),
                                        size: 14,
                                      ),
                                    ),
                                    Text('Paid on 26-Jan-2023')
                                  ],
                                ),
                              ),
                              DataCell(
                                defaultCellText(text: '₱ 100.00'),
                              ),
                              DataCell(defaultCellText(text: 'PEDRO MALAKI'))
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Text defaultCellText({ required String text }) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
