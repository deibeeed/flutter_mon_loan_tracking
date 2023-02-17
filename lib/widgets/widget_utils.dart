import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/payment_status.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';

Text defaultCellText({ required String text }) {
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
  );
}