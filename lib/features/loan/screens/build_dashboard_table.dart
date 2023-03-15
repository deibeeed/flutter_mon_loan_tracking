part of 'add_loan_screen.dart';

Widget buildDashboardTable({
  required BuildContext context,
  required LoanBloc loanBloc,
  required PagingController<int, LoanSchedule> pagingController,
  bool finiteSize = false
}) {

  return SizedBox(
    width: !finiteSize ? null : 1072,
    height: !finiteSize ? null : 1180,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gridHeaderItem(
                context: context,
                name: Constants.loan_schedule_table_columns[0],
              ),
              gridHeaderItem(
                  context: context,
                  name: Constants.loan_schedule_table_columns[1],
                  width: 160),
              gridHeaderItem(
                context: context,
                name: Constants.loan_schedule_table_columns[2],
              ),
              gridHeaderItem(
                  context: context,
                  name: Constants.loan_schedule_table_columns[3],
                  width: 180),
              gridHeaderItem(
                context: context,
                name: Constants.loan_schedule_table_columns[4],
              ),
              gridHeaderItem(
                context: context,
                name: Constants.loan_schedule_table_columns[5],
              ),
              gridHeaderItem(
                context: context,
                name: Constants.loan_schedule_table_columns[6],
              ),
            ],
          ),
        ),
        BlocBuilder<LoanBloc, LoanState>(
            builder: (context, state) {
              if (loanBloc.clientLoanSchedules.isEmpty) {
                return Container();
              }
              return SizedBox(
                height: 1000,
                child: PagedGridView(
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<LoanSchedule>(
                      itemBuilder: (context, schedule, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              gridItem(
                                child: defaultCellText(
                                  text: '${index + 1}',
                                ),
                              ),
                              gridItem(
                                child: defaultCellText(
                                  text: Constants.defaultDateFormat.format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      schedule.date.toInt(),
                                    ),
                                  ),
                                ),
                              ),
                              gridItem(
                                child: Center(
                                  child: defaultCellText(
                                    text: schedule.outstandingBalance.toCurrency(),
                                  ),
                                ),
                              ),
                              gridItem(
                                child: Center(
                                  child: defaultCellText(
                                    text: schedule.monthlyAmortization.toCurrency(),
                                  ),
                                ),
                              ),
                              gridItem(
                                child: Center(
                                  child: defaultCellText(
                                    text: schedule.principalPayment.toCurrency(),
                                  ),
                                ),
                              ),
                              gridItem(
                                child: Center(
                                  child: defaultCellText(
                                    text: schedule.interestPayment.toCurrency(),
                                  ),
                                ),
                              ),
                              gridItem(
                                child: Center(
                                  child: defaultCellText(
                                    text: schedule.incidentalFee.toCurrency(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, mainAxisExtent: 72, crossAxisSpacing: 16),
                ),
              );
            }),
      ],
    ),
  );
}