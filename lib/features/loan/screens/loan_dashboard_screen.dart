import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/general_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan_display.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/payment_status.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LoanDashboardScreen extends StatelessWidget {
  LoanDashboardScreen({super.key}) : super();

  final _pagingController = PagingController<int, LoanDisplay>(firstPageKey: 0);
  bool _didAddPageRequestListener = false;

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final loanBloc = BlocProvider.of<LoanBloc>(context)
      ..getAllUsers()
      ..getAllLots();

    if (!_didAddPageRequestListener) {
      _pagingController.addPageRequestListener((pageKey) {
        loanBloc.getAllLoans();
      });
      // _scrollController.addListener(() {
      //   printd('pixesl: ${_scrollController.position.pixels}');
      //   if (_scrollController.position.atEdge) {
      //     final isTop = _scrollController.position.pixels == 0;
      //     if (isTop) {
      //       printd('At the top');
      //     } else {
      //       loanBloc.getAllLoans();
      //     }
      //   }
      // });
      _didAddPageRequestListener = true;
    }

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
                      child: BlocBuilder<LoanBloc, LoanState>(
                        buildWhen: (previous, current) =>
                            current is LoanSuccessState,
                        builder: (context, state) {
                          return NotificationListener(
                              onNotification: (ScrollMetricsNotification
                                  scrollNotification) {
                                printd(
                                    'scrollNotification: $scrollNotification');
                                printd(
                                    'pixels: ${scrollNotification.metrics.pixels}');
                                printd(
                                    'maxScrollExtent: ${scrollNotification.metrics.maxScrollExtent}');
                                if (scrollNotification.metrics.pixels ==
                                    scrollNotification
                                        .metrics.maxScrollExtent) {
                                  loanBloc.getAllLoans();
                                } else if (scrollNotification.metrics.atEdge) {
                                  loanBloc.getAllLoans();
                                }
                                return true;
                              },
                              child: SingleChildScrollView(
                                // controller: _scrollController,
                                child: DataTable(
                                  dataRowHeight: 72,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                    (states) => Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withOpacity(0.32),
                                  ),
                                  columns:
                                      Constants.loan_dashboard_table_columns
                                          .map(
                                            (name) => DataColumn(
                                              label: Text(
                                                name.toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.apply(
                                                      fontWeightDelta: 3,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  rows: loanBloc.allLoans
                                      .map((loanDisplay) => DataRow(cells: [
                                            DataCell(
                                              defaultCellText(
                                                text: loanDisplay.schedule.date
                                                    .toDefaultDate(),
                                              ),
                                            ),
                                            DataCell(
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  defaultCellText(
                                                    text: loanBloc
                                                        .mappedUsers[loanDisplay
                                                            .loan.clientId]!
                                                        .completeName,
                                                  ),
                                                  Text(loanBloc
                                                      .mappedUsers[loanDisplay
                                                          .loan.clientId]!
                                                      .email)
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              defaultCellText(
                                                text: loanBloc
                                                    .mappedLots[
                                                        loanDisplay.loan.lotId]!
                                                    .completeBlockLotNo,
                                              ),
                                            ),
                                            DataCell(
                                              _paymentStatusWidget(
                                                context: context,
                                                schedule: loanDisplay.schedule,
                                              ),
                                            ),
                                            DataCell(
                                              defaultCellText(
                                                  text: loanDisplay.schedule
                                                      .monthlyAmortization
                                                      .toCurrency()),
                                            ),
                                            DataCell(defaultCellText(
                                                text: 'DAVID DULDULAO'))
                                          ]))
                                      .toList(),
                                ),
                              ));
                        },
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

  Text defaultCellText({required String text}) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _paymentStatusWidget({
    required BuildContext context,
    required LoanSchedule schedule,
  }) {
    final status =
        context.read<LoanBloc>().getPaymentStatus(schedule: schedule);
    // success text color 0xff007F00
    // success background color 0xffCDFFCD
    final themeColorScheme = Theme.of(context).colorScheme;
    var textColor = themeColorScheme.tertiary;
    var backgroundColor = themeColorScheme.tertiaryContainer;
    var payStatus = 'Paid on ${schedule.paidOn?.toDefaultDate()}';

    if (status == PaymentStatus.overdue) {
      textColor = themeColorScheme.error;
      backgroundColor = themeColorScheme.errorContainer;
    }

    if (status == PaymentStatus.nextPayment) {
      textColor = themeColorScheme.surfaceVariant;
      backgroundColor = themeColorScheme.onSurfaceVariant;
      payStatus = 'Pay on ${schedule.date.toDefaultDate()}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Chip(
          label: Text(
            status.value,
            style:
                TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
          backgroundColor: backgroundColor,
          avatar: Icon(
            Icons.fiber_manual_record_rounded,
            color: textColor,
            size: 14,
          ),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          payStatus,
        )
      ],
    );
  }
}
