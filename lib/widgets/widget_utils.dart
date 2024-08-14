import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_display.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/payment_status.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

Text defaultCellText({required String text}) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget paymentStatusWidget({
  required BuildContext context,
  required LoanSchedule schedule,
  bool showPaymentControls = false,
}) {
  final loanBloc = context.read<LoanBloc>();
  final status = loanBloc.getPaymentStatus(schedule: schedule);
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
    textColor = themeColorScheme.surfaceContainerHighest;
    backgroundColor = themeColorScheme.onSurfaceVariant;
    payStatus = 'Pay on ${schedule.date.toDefaultDate()}';
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Chip(
            label: Text(
              status.value,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            backgroundColor: backgroundColor,
            avatar: Icon(
              Icons.fiber_manual_record_rounded,
              color: textColor,
              size: 14,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            payStatus,
          )
        ],
      ),
      const SizedBox(
        width: 8,
      ),
      Visibility(
        visible: showPaymentControls,
        child: InkWell(
          onTap: () {
            final formKey = GlobalKey<FormBuilderState>(debugLabel: 'payment');

            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Payment'),
                    content: FormBuilder(
                      key: formKey,
                      child: FormBuilderTextField(
                        name: 'amount',
                        initialValue: schedule.monthlyAmortization.toCurrency(),
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            var text = '';
                            if (newValue.text.isEmpty) {
                              text = '';
                            }

                            print('oldValue: ${oldValue.text}');
                            print('newValue: ${newValue.text}');

                            try {
                              final base = Constants
                                  .defaultCurrencyFormatOptionalDecimal
                                  .parse(newValue.text);
                              print('base: $base');

                              if (newValue.text.endsWith('.')) {
                                text = newValue.text;
                              } else {
                                text = base.toCurrency(
                                  optionalDecimal: true,
                                );
                              }
                            } on FormatException catch (err) {
                              print(err);
                              final base = Constants
                                  .defaultCurrencyFormatOptionalDecimal
                                  .parse(oldValue.text);
                              text = base.toCurrency(optionalDecimal: true);

                              if (newValue.text == Constants.currency) {
                                text = '';
                              }
                            }

                            return TextEditingValue(
                              text: text,
                              selection: TextSelection.collapsed(
                                offset: text.length,
                              ),
                            );
                          }),
                        ],
                        valueTransformer: (val) {
                          if (val == null) {
                            return null;
                          }

                          return Constants.defaultCurrencyFormat.parse(val);
                        },
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(
                                errorText: 'Please enter amount'),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () {
                          if (formKey.currentState?.saveAndValidate() ??
                              false) {
                            loanBloc.payLoanSchedule(
                              schedule: schedule,
                              payment: formKey.currentState!.value['amount']
                                  as double,
                            );

                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  );
                });
          },
          child: SvgPicture.asset(
            'assets/icons/online-payment.svg',
            width: 24,
            height: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ],
  );
}

Widget gridHeaderItem({
  required BuildContext context,
  required String name,
  double width = 140,
  double height = 72,
}) {
  return Container(
    width: width,
    height: height,
    alignment: Alignment.centerLeft,
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Text(
      name.toUpperCase(),
      style: Theme.of(context).textTheme.titleMedium?.apply(
            fontWeightDelta: 3,
            color: Theme.of(context).colorScheme.secondary,
          ),
    ),
  );
}

Widget gridItem({
  double width = 140,
  required Widget child,
}) {
  return SizedBox(
    width: width,
    child: child,
  );
}

Widget buildDashboardTable({
  required BuildContext context,
  required LoanBloc loanBloc,
  required PagingController<int, LoanSchedule> pagingController,
  String? userId,
  bool finiteSize = false,
  bool isSmallScreen = false,
  // mostly used in userDetailsScreen
  bool withStatus = false,
  UserType loggedInUserType = UserType.customer,
}) {
  return SizedBox(
    width: !finiteSize
        ? null
        : !withStatus
            ? 1072
            : 1212,
    height: !finiteSize ? null : 1180,
    child: Column(
      children: [
        Container(
          constraints: isSmallScreen
              ? const BoxConstraints(maxHeight: 16800, maxWidth: 1212)
              : null,
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
                width: 160,
              ),
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
              if (withStatus) ...[
                gridHeaderItem(
                  context: context,
                  name: Constants.loan_schedule_table_columns[7],
                ),
                gridHeaderItem(
                  context: context,
                  name: Constants.loan_schedule_table_columns[8],
                ),
              ],
            ],
          ),
        ),
        BlocBuilder<LoanBloc, LoanState>(builder: (context, state) {
          if (loanBloc.clientLoanSchedules.isEmpty) {
            return Container();
          }
          return Container(
            constraints: isSmallScreen
                ? const BoxConstraints(maxHeight: 16800, maxWidth: 1212)
                : null,
            height: !isSmallScreen ? 1000 : null,
            child: PagedGridView(
              pagingController: pagingController,
              physics:
                  !isSmallScreen ? null : const NeverScrollableScrollPhysics(),
              shrinkWrap: isSmallScreen,
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
                            text: schedule.beginningBalance.toCurrency(),
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
                      if (withStatus) ...[
                        gridItem(
                          child: Center(
                            child: defaultCellText(
                              text: schedule.extraPayment?.toCurrency() ?? '',
                            ),
                          ),
                        ),
                        gridItem(
                          width: 180,
                          child: Center(
                            child: paymentStatusWidget(
                              context: context,
                              schedule: schedule,
                              showPaymentControls: schedule.paidOn == null &&
                                  ![UserType.customer, UserType.accountant]
                                      .contains(loggedInUserType),
                            ),
                          ),
                        ),
                      ],
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
