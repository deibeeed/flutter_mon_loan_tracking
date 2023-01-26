import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class LoanDashboardScreen extends StatelessWidget {
  const LoanDashboardScreen({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0,
        style: BorderStyle.none,
      ),
    );

    return Scaffold(
      body: Card(
        color: Colors.white,
        shadowColor: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 24, bottom: 24),
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
                          label: const Text('Search users by name or email'),
                          // floatingLabelBehavior: FloatingLabelBehavior.never,
                          filled: true,
                          fillColor:
                              Theme.of(context).colorScheme.secondaryContainer,
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
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.32),
                  ),
                  columns: [
                    for (String name in Constants.loan_dashboard_table_columns)
                      DataColumn(
                          label: Text(
                        name.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.apply(
                              fontWeightDelta: 3,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ))
                  ],
                  rows: [],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
