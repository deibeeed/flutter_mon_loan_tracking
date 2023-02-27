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
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LoanDashboardScreen extends StatelessWidget {
  LoanDashboardScreen({super.key}) : super();

  final _pagingController = PagingController<int, LoanDisplay>(firstPageKey: 0);
  bool _didAddPageRequestListener = false;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loanBloc = BlocProvider.of<LoanBloc>(context)
      ..getAllUsers()
      ..getAllLots();

    if (!_didAddPageRequestListener) {
      // _pagingController.addPageRequestListener((pageKey) {
      //   loanBloc.getAllLoans();
      // });
      _scrollController.addListener(() {
        if (_scrollController.position.atEdge) {
          final isTop = _scrollController.position.pixels == 0;
          if (isTop) {
            printd('At the top');
          } else {
            if (!loanBloc.loansBottomReached) {
              loanBloc.getAllLoans();
            }
          }
        }
      });
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

    final shortestSide = screenSize.shortestSide;
    var searchTextFieldPadding = const EdgeInsets.only(
      left: 32,
      right: 32,
      top: 20,
      bottom: 20,
    );
    var searchContainerPadding = const EdgeInsets.only(
      left: 24,
      top: 24,
      bottom: 24,
    );
    var searchButtonPadding = const EdgeInsets.all(22);
    var searchTextFieldWidth = screenSize.width * 0.3;
    var isLargeScreenBreakpoint = false;

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      searchTextFieldPadding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 16,
      );
      searchContainerPadding = const EdgeInsets.all(16);
      searchButtonPadding = const EdgeInsets.all(16);
      searchTextFieldWidth = screenSize.width * 0.5;

      isLargeScreenBreakpoint = true;
    }

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
                          onPressed: () {
                            loanBloc.filterByStatus(
                                status: Constants
                                    .loan_dashboard_general_filters[i]);
                            generalFilterCubit.select(position: i);
                          },
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
              shadowColor: Colors.black,
              elevation: 16,
              child: Column(
                children: [
                  Padding(
                    padding: searchContainerPadding,
                    child: Row(
                      children: [
                        // OutlinedButton(
                        //   onPressed: () => printd('hello'),
                        //   style: OutlinedButton.styleFrom(
                        //     padding: const EdgeInsets.all(22),
                        //     foregroundColor: Theme.of(context)
                        //         .colorScheme
                        //         .secondary
                        //         .withOpacity(0.8),
                        //     side: BorderSide(
                        //       width: 1.5,
                        //       color: Theme.of(context)
                        //           .colorScheme
                        //           .secondary
                        //           .withOpacity(0.8),
                        //     ),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       const Icon(Icons.filter_alt_rounded),
                        //       Text(
                        //         'FILTER',
                        //         style: Theme.of(context).textTheme.titleMedium,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(
                        //   width: 32,
                        // ),
                        SizedBox(
                          width: searchTextFieldWidth,
                          child: TextFormField(
                            // style: TextStyle(fontSize: 16, ),
                            controller: _searchController,
                            decoration: InputDecoration(
                                contentPadding: searchTextFieldPadding,
                                label: const Text(
                                    'Search loan schedules by user name or email'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                border: defaultBorder,
                                enabledBorder: defaultBorder,
                                focusedBorder: defaultBorder),
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (value) =>
                                loanBloc.search(query: value),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              loanBloc.search(query: _searchController.text),
                          style: OutlinedButton.styleFrom(
                            padding: searchButtonPadding,
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
                              const Icon(Icons.search_rounded),
                              Text(
                                'Search',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previous, current) =>
                              current is LoanLoadingState ||
                              current is LoanErrorState,
                          builder: (context, state) {
                            if (state is LoanLoadingState) {
                              if (state.isLoading) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                            }

                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox.expand(
                      child: BlocBuilder<LoanBloc, LoanState>(
                        buildWhen: (previous, current) =>
                            current is LoanSuccessState,
                        builder: (context, state) {
                          if (!isLargeScreenBreakpoint) {
                            return _buildTableDashboard(
                              context: context,
                              loanBloc: loanBloc,
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildTableDashboard(
                              context: context,
                              loanBloc: loanBloc,
                            ),
                          );
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

  Widget _buildTableDashboard(
      {required BuildContext context, required LoanBloc loanBloc}) {
    return NotificationListener(
      onNotification: (ScrollMetricsNotification scrollNotification) {
        if (!loanBloc.loansBottomReached) {
          if (scrollNotification.metrics.pixels == 0 &&
              scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent) {
            loanBloc.getAllLoans();
          }
        }
        /*else if (scrollNotification.metrics.atEdge) {
                                  loanBloc.getAllLoans();
                                }*/
        return true;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: DataTable(
          dataRowHeight: 72,
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Theme.of(context).colorScheme.secondaryContainer,
          ),
          columns: Constants.loan_dashboard_table_columns
              .map(
                (name) => DataColumn(
                  label: Text(
                    name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.apply(
                          fontWeightDelta: 3,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ),
              )
              .toList(),
          rows: loanBloc.filteredLoans
              .map(
                (loanDisplay) => DataRow(
                  cells: [
                    DataCell(
                      defaultCellText(
                        text: loanDisplay.schedule.date.toDefaultDate(),
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          defaultCellText(
                            text: loanBloc
                                .mappedUsers[loanDisplay.loan.clientId]!
                                .completeName,
                          ),
                          Text(loanBloc
                              .mappedUsers[loanDisplay.loan.clientId]!.email)
                        ],
                      ),
                    ),
                    DataCell(
                      defaultCellText(
                        text: loanBloc.mappedLots[loanDisplay.loan.lotId]!
                            .completeBlockLotNo,
                      ),
                    ),
                    DataCell(
                      paymentStatusWidget(
                        context: context,
                        schedule: loanDisplay.schedule,
                      ),
                    ),
                    DataCell(
                      defaultCellText(
                          text: loanDisplay.schedule.monthlyAmortization
                              .toCurrency()),
                    ),
                    DataCell(defaultCellText(text: 'DAVID DULDULAO'))
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
