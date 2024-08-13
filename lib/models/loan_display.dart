import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';

class LoanDisplay {
  final Loan loan;
  final LoanSchedule schedule;

  const LoanDisplay({ required this.loan, required this.schedule,});
}