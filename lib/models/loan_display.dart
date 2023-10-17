import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/lot.dart';

class LoanDisplay {
  final Loan loan;
  final LoanSchedule schedule;
  final Lot lot;

  const LoanDisplay({ required this.loan, required this.schedule, required this.lot });
}