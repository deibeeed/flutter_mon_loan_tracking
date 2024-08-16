import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/general_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/reports_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan_display.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:gap/gap.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LoanDashboardScreen extends StatefulWidget {
  LoanDashboardScreen({super.key}) : super();

  @override
  State<StatefulWidget> createState() => _LoanDashboardScreenState();
}

class _LoanDashboardScreenState extends State<LoanDashboardScreen> {
  final _pagingController = PagingController<int, LoanDisplay>(firstPageKey: 0);
  bool _didAddPageRequestListener = false;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final userBloc = context.read<UserBloc>()
      ..getAllUsers();
    String? clientId;

    if (userBloc
        .getLoggedInUser()
        ?.type == UserType.customer) {
      clientId = userBloc
          .getLoggedInUser()
          ?.id;
    }

    // context.read<LoanBloc>().getAllLoans(clearList: true, clientId: clientId);

    if (!_didAddPageRequestListener) {
      _pagingController.addPageRequestListener((pageKey) {
        context
            .read<LoanBloc>()
            .getAllLoans(clearList: pageKey == 0, clientId: clientId);
      });
      _didAddPageRequestListener = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanBloc = BlocProvider.of<LoanBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);

    final screenSize = MediaQuery
        .of(context)
        .size;
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
        body: BlocListener<LoanBloc, LoanState>(
          listener: (context, state) {
            if (state is LoanDisplaySummaryState) {
              _pagingController.value = PagingState(
                nextPageKey: state.nextPage,
                itemList: state.items,
                error: state.error,
              );

              // _pagingController.appendPage(
              //   state.items,
              //   state.nextPage,
              // );
            }
          },
          child: Column(
            children: [
              BlocBuilder<ReportsBloc, ReportsState>(
                builder: (context, state) {
                  if (state is ShowReportState) {
                    final colorScheme = Theme
                        .of(context)
                        .colorScheme;

                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 300,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: BarChart(
                                    BarChartData(
                                      barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem:
                                              (group, groupIndex, rod,
                                              rodIndex) {
                                            return BarTooltipItem(
                                              rod.toY.toCurrency(),
                                              const TextStyle(),
                                            );
                                          },
                                        ),
                                      ),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          showingTooltipIndicators: [0, 1],
                                          barRods: [
                                            BarChartRodData(
                                              toY: state.totalLoanAmount,
                                              color: colorScheme.primary,
                                              width: 80,
                                            ),
                                            BarChartRodData(
                                              toY: state
                                                  .totalExpectedCollections,
                                              color: colorScheme
                                                  .primaryContainer,
                                              width: 80,
                                            ),
                                          ],
                                        ),
                                      ],
                                      maxY: state.totalExpectedCollections *
                                          1.2,
                                      gridData: const FlGridData(
                                        show: false,
                                      ),
                                      borderData: FlBorderData(
                                          border: const Border(
                                            left: BorderSide(
                                              color: Colors.white,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.white,
                                            ),
                                          )),
                                      titlesData: const FlTitlesData(
                                        rightTitles: AxisTitles(),
                                        topTitles: AxisTitles(
                                          axisNameWidget: Text(''),
                                        ),
                                        bottomTitles: AxisTitles(),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const Gap(8),
                                        const Text('Total Loan amount'),
                                      ],
                                    ),
                                    const Gap(8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const Gap(8),
                                        const Text(
                                            'Total Expected collections'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 300,
                            child: Row(
                              children: [
                                Expanded(
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          color: colorScheme.tertiaryContainer,
                                          value: state
                                              .totalExpectedProfitPercent,
                                          radius: 76,
                                          title: state.totalExpectedProfit
                                              .toCurrency(),
                                          titlePositionPercentageOffset: 2,
                                        ),
                                        PieChartSectionData(
                                          color: colorScheme.tertiary,
                                          value: state
                                              .totalActualCollectionsProfitPercent,
                                          radius: 100,
                                          title: state
                                              .totalActualCollectionsProfit
                                              .toCurrency(),
                                          titlePositionPercentageOffset: 1.5,
                                          // titleStyle: const TextStyle(
                                          //   color: Colors.black,
                                          // ),
                                        ),
                                      ],
                                      pieTouchData: PieTouchData(
                                        touchCallback: (event,
                                            touchResponse) {},
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .tertiaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const Gap(8),
                                        const Text('Expected collections'),
                                      ],
                                    ),
                                    const Gap(8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: colorScheme.tertiary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const Gap(8),
                                        Text('Actual collections @ ${state
                                            .totalActualCollectionsProfitPercent
                                            .toPercent()}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 300,
                            child: Center(
                              child: SizedBox(
                                height: 230,
                                width: 450,
                                child: Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${state.overdueCount}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 36,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Text(
                                        'Overdue accounts',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Container();
                },
              ),
              const Gap(24),
              // BlocBuilder<GeneralFilterSelectionCubit, GeneralFilterSelectionState>(
              //   builder: (context, state) {
              //     var position = 0;
              //
              //     if (state is FilterSelectedState) {
              //       position = state.position;
              //     }
              //
              //     return Row(
              //       children: [
              //         for (var i = 0;
              //             i < Constants.loan_dashboard_general_filters.length;
              //             i++)
              //           Column(
              //             children: [
              //               TextButton(
              //                 onPressed: () {
              //                   loanBloc.filterByStatus(
              //                     status:
              //                         Constants.loan_dashboard_general_filters[i],
              //                   );
              //                   generalFilterCubit.select(position: i);
              //                 },
              //                 child: Text(
              //                   Constants.loan_dashboard_general_filters[i],
              //                   style: Theme.of(context)
              //                       .textTheme
              //                       .titleMedium
              //                       ?.apply(
              //                           fontSizeDelta: 2,
              //                           fontWeightDelta: 2,
              //                           color: Theme.of(context)
              //                               .colorScheme
              //                               .secondary),
              //                 ),
              //               ),
              //               Visibility(
              //                 visible: position == i,
              //                 child: Container(
              //                   height: 2,
              //                   width: 56,
              //                   color: Theme.of(context).colorScheme.secondary,
              //                 ),
              //               )
              //             ],
              //           ),
              //       ],
              //     );
              //   },
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 16),
              //   child: Container(
              //     color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              //     height: 2,
              //     width: double.infinity,
              //   ),
              // ),
              Expanded(
                child: Card(
                  shadowColor: Colors.black,
                  elevation: 16,
                  child: Column(
                    children: [
                      // Padding(
                      //   padding: searchContainerPadding,
                      //   child: Row(
                      //     children: [
                      //       // OutlinedButton(
                      //       //   onPressed: () => print('hello'),
                      //       //   style: OutlinedButton.styleFrom(
                      //       //     padding: const EdgeInsets.all(22),
                      //       //     foregroundColor: Theme.of(context)
                      //       //         .colorScheme
                      //       //         .secondary
                      //       //         .withOpacity(0.8),
                      //       //     side: BorderSide(
                      //       //       width: 1.5,
                      //       //       color: Theme.of(context)
                      //       //           .colorScheme
                      //       //           .secondary
                      //       //           .withOpacity(0.8),
                      //       //     ),
                      //       //   ),
                      //       //   child: Row(
                      //       //     children: [
                      //       //       const Icon(Icons.filter_alt_rounded),
                      //       //       Text(
                      //       //         'FILTER',
                      //       //         style: Theme.of(context).textTheme.titleMedium,
                      //       //       ),
                      //       //     ],
                      //       //   ),
                      //       // ),
                      //       // const SizedBox(
                      //       //   width: 32,
                      //       // ),
                      //       SizedBox(
                      //         width: searchTextFieldWidth,
                      //         child: TextFormField(
                      //           // style: TextStyle(fontSize: 16, ),
                      //           controller: _searchController,
                      //           decoration: InputDecoration(
                      //               contentPadding: searchTextFieldPadding,
                      //               label: const Text(
                      //                   'Search loan schedules by user name or email'),
                      //               floatingLabelBehavior:
                      //                   FloatingLabelBehavior.never,
                      //               filled: true,
                      //               fillColor: Theme.of(context)
                      //                   .colorScheme
                      //                   .secondaryContainer,
                      //               border: defaultBorder,
                      //               enabledBorder: defaultBorder,
                      //               focusedBorder: defaultBorder),
                      //           textInputAction: TextInputAction.search,
                      //           onFieldSubmitted: (value) =>
                      //               loanBloc.search(query: value),
                      //         ),
                      //       ),
                      //       const SizedBox(
                      //         width: 16,
                      //       ),
                      //       OutlinedButton(
                      //         onPressed: () =>
                      //             loanBloc.search(query: _searchController.text),
                      //         style: OutlinedButton.styleFrom(
                      //           padding: searchButtonPadding,
                      //           foregroundColor: Theme.of(context)
                      //               .colorScheme
                      //               .secondary
                      //               .withOpacity(0.8),
                      //           side: BorderSide(
                      //             width: 1.5,
                      //             color: Theme.of(context)
                      //                 .colorScheme
                      //                 .secondary
                      //                 .withOpacity(0.8),
                      //           ),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             const Icon(
                      //               Icons.search_rounded,
                      //               size: 18,
                      //             ),
                      //             Text(
                      //               'Search',
                      //               // style: Theme.of(context).textTheme.titleMedium,
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       BlocBuilder<LoanBloc, LoanState>(
                      //         buildWhen: (previous, current) =>
                      //             current is LoanLoadingState ||
                      //             current is LoanErrorState,
                      //         builder: (context, state) {
                      //           if (state is LoanLoadingState) {
                      //             if (state.isLoading) {
                      //               return const Padding(
                      //                 padding: EdgeInsets.all(16),
                      //                 child: SizedBox(
                      //                   width: 32,
                      //                   height: 32,
                      //                   child: CircularProgressIndicator(),
                      //                 ),
                      //               );
                      //             }
                      //           }
                      //
                      //           return Container();
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (!isLargeScreenBreakpoint) {
                              return _buildDashboardTable(
                                userBloc: userBloc,
                                loanBloc: loanBloc,
                              );
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                height: 400,
                                width: 932,
                                child: _buildDashboardTable(
                                  userBloc: userBloc,
                                  loanBloc: loanBloc,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildDashboardTable({
    required UserBloc userBloc,
    required LoanBloc loanBloc,
  }) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            color: Theme
                .of(context)
                .colorScheme
                .secondaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gridHeaderItem(
                  context: context,
                  name: Constants.loan_dashboard_table_columns[0],
                ),
                gridHeaderItem(
                  context: context,
                  name: Constants.loan_dashboard_table_columns[1],
                  width: 160,
                ),
                gridHeaderItem(
                  context: context,
                  name: Constants.loan_dashboard_table_columns[3],
                  width: 180,
                ),
                gridHeaderItem(
                  context: context,
                  name: Constants.loan_dashboard_table_columns[2],
                ),
              ],
            ),
          ),
        ),
        PagedSliverGrid(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<LoanDisplay>(
              itemBuilder: (context, loanDisplay, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      gridItem(
                        child: defaultCellText(
                          text: loanDisplay.schedule.date.toDefaultDate(),
                        ),
                      ),
                      gridItem(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            defaultCellText(
                              text: userBloc.mappedUsers[loanDisplay.loan
                                  .clientId]!
                                  .completeName,
                            ),
                            Text(userBloc.mappedUsers[loanDisplay.loan
                                .clientId]!
                                .email ??
                                '')
                          ],
                        ),
                      ),
                      gridItem(
                        child: defaultCellText(
                          text:
                          loanDisplay.schedule.monthlyAmortization.toCurrency(),
                        ),
                      ),
                      gridItem(
                        width: 180,
                        child: paymentStatusWidget(
                            context: context,
                            schedule: loanDisplay.schedule,
                            showPaymentControls:
                            loanDisplay.schedule.paidOn == null &&
                                ![
                                  UserType.customer,
                                  UserType.accountant
                                ].contains(userBloc
                                    .getLoggedInUser()
                                    ?.type)),
                      ),
                    ],
                  ),
                );
              }),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, mainAxisExtent: 72, crossAxisSpacing: 16),
        )
      ],
    );
  }
}
