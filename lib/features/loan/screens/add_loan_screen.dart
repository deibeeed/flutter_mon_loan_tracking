import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_mon_loan_tracking/widgets/pdf_generator.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'add_loan_screen_large.dart';

part 'add_loan_screen_small.dart';

class AddLoanScreen extends StatefulWidget {
  AddLoanScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
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
  final agentAssistedController = TextEditingController();
  final dateController = TextEditingController(
      text: Constants.defaultDateFormat.format(DateTime.now()));
  final pagingController = PagingController<int, LoanSchedule>(firstPageKey: 0);
  var _downpaymentPopulated = false;

  @override
  void deactivate() {
    context.read<LoanBloc>().reset();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserBloc>().getAllUsers();
    final loanBloc = BlocProvider.of<LoanBloc>(context)..getSettings();
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);
    var computationDetailsWidth = screenSize.width * 0.2;

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      computationDetailsWidth = screenSize.width * 0.3;
    }

    final width = screenSize.width;
    final computedWidth = width * 0.88;
    var appBarHeight = screenSize.height * 0.16;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var titleTextStyle = Theme.of(context).textTheme.displaySmall;
    var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
    var avatarSize = 56.0;
    var contentPadding = const EdgeInsets.all(58);
    var appBarBottomPadding = 48.0;
    var isLargeScreenBreakpoint = false;

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      titleTextStyle = Theme.of(context).textTheme.headlineMedium;
      avatarTextStyle = Theme.of(context).textTheme.titleSmall;
      avatarSize = 48;
      contentPadding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 16,
      );
      appBarBottomPadding = 24;
      isLargeScreenBreakpoint = true;
    }

    return BlocListener<LoanBloc, LoanState>(
      listener: (context, state) {
        if (state is LoanSuccessState) {
          if (loanBloc.selectedUser != null) {
            firstNameController.text = loanBloc.selectedUser!.firstName;
          }

          if (loanBloc.selectedLot != null && loanBloc.settings != null) {
            final lot = loanBloc.selectedLot!;
            final settings = loanBloc.settings!;
            lotAreaController.text = lot.area.toString();
            downpaymentController.text = loanBloc
                .computeDownPaymentRate(
              withCustomTCP: tcpController.text.isNotEmpty
                  ? Constants.defaultCurrencyFormat
                  .parse(tcpController.text)
                  : null,
            )
                .toCurrency();

            final lotCategory = settings.lotCategories.firstWhereOrNull(
              (category) => category.key == lot.lotCategoryKey,
            );

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

            pagingController.value = PagingState(
              itemList: loanBloc.clientLoanSchedules,
            );
          }
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
        appBar: !widget.isMobile()
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight),
                child: AppBar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.48),
                  leading: !widget.isMobile()
                      ? Container()
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => GoRouter.of(context).pop(),
                        ),
                  bottom: PreferredSize(
                    preferredSize: Size.zero,
                    child: Container(
                      width: computedWidth,
                      margin: EdgeInsets.only(bottom: appBarBottomPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add loan',
                            style: titleTextStyle?.apply(color: Colors.white),
                          ),
                          SizedBox(
                            width: avatarSize,
                            height: avatarSize,
                            child: InkWell(
                              onTap: () {
                                final user =
                                    context.read<UserBloc>().getLoggedInUser();
                                if (user != null) {
                                  GoRouter.of(context)
                                      .push('/users/${user.id}');
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    context
                                            .read<UserBloc>()
                                            .getLoggedInUser()
                                            ?.initials ??
                                        'No',
                                    style: avatarTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: loginContainerRadius,
                      bottomRight: loginContainerRadius,
                    ),
                  ),
                ),
              ),
        body: shortestSide <= Constants.smallScreenShortestSideBreakPoint
            ? buildSmallScreenBody(
                context: context,
                loanBloc: loanBloc,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                blockNoController: blockNoController,
                lotNoController: lotNoController,
                lotAreaController: lotAreaController,
                lotCategoryController: lotCategoryController,
                pricePerSqmController: pricePerSqmController,
                tcpController: tcpController,
                loanDurationController: loanDurationController,
                downpaymentController: downpaymentController,
                discountController: discountController,
                discountDescriptionController: discountDescriptionController,
                agentAssistedController: agentAssistedController,
                dateController: dateController,
                pagingController: pagingController,
              )
            : buildLargeScreenBody(
                context: context,
                loanBloc: loanBloc,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                blockNoController: blockNoController,
                lotNoController: lotNoController,
                lotAreaController: lotAreaController,
                lotCategoryController: lotCategoryController,
                pricePerSqmController: pricePerSqmController,
                tcpController: tcpController,
                loanDurationController: loanDurationController,
                downpaymentController: downpaymentController,
                discountController: discountController,
                discountDescriptionController: discountDescriptionController,
                agentAssistedController: agentAssistedController,
                dateController: dateController,
                pagingController: pagingController,
              ),
      ),
    );
  }

  Widget _buildTable({
    required BuildContext context,
    required LoanBloc loanBloc,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
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
            .mapIndexed(
              (i, schedule) => DataRow(
                cells: [
                  DataCell(
                    defaultCellText(
                      text: '${i + 1}',
                    ),
                  ),
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
      ),
    );
  }
}
