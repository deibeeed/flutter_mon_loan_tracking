import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_schedule_repository.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:jiffy/jiffy.dart';

part 'reports_event.dart';

part 'reports_state.dart';

/// reports to be generated:
///   Total loan amount vs total expected collections
///   Total expected profit vs Actual collections profit
///   Overdue count
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc(BuildContext context)
      : _loanRepository = context.read<LoanRepository>(),
        _loanScheduleRepository = context.read<LoanScheduleRepository>(),
        super(ReportsInitial()) {
    on(_handleGenerateReportsEvent);
  }

  final LoanRepository _loanRepository;

  final LoanScheduleRepository _loanScheduleRepository;

  void initialize() {
    add(GenerateReportsEvent());
  }

  Future<void> _handleGenerateReportsEvent(
      GenerateReportsEvent event, Emitter<ReportsState> emit) async {
    try {
      // get total loan amount;
      final data = await Future.wait([
        _loanRepository.allLoans(),
        _loanScheduleRepository.all(),
      ]);
      final loans = data.first as List<Loan>;
      final schedules = data.last as List<LoanSchedule>;

      final reportData = await Future.wait([
        _totalLoanAmount(loans),
        _totalExpectedCollections(loans),
        _totalActualCollectionProfit(schedules),
        _overdueCount(schedules, loans),
      ]);

      printd('total expected profit: ${reportData[1] - reportData[0]}');
      printd(
          'total expected profit: ${reportData[2] / (reportData[1] - reportData[0]) * 100}');

      emit(
        ShowReportState(
          totalLoanAmount: reportData[0],
          totalExpectedCollections: reportData[1],
          totalExpectedProfitPercent: 100,
          totalActualCollectionsProfitPercent:
              reportData[2] / (reportData[1] - reportData[0]) * 100,
          totalExpectedProfit: reportData[1] - reportData[0],
          totalActualCollectionsProfit: reportData[2],
          overdueCount: reportData[3].toInt(),
        ),
      );
    } catch (err) {
      printd(err);
    }
  }

  Future<double> _totalLoanAmount(List<Loan> loans) {
    final total = loans.fold(0.0, (pV, e) => pV + e.amount.toDouble());

    return Future.value(total);
  }

  Future<double> _totalExpectedCollections(List<Loan> loans) {
    final total = loans.fold(0.0, (pV, e) {
      final interestRate = (e.monthlyInterestRate * e.monthsToPay) / 100;
      return (e.amount * interestRate) + e.amount + pV;
    });

    return Future.value(total);
  }

  Future<double> _totalActualCollectionProfit(List<LoanSchedule> schedules) {
    final total = schedules
        .where((sched) => sched.paidOn != null)
        .fold(0.0, (pV, e) => pV + e.interestPayment);

    return Future.value(total);
  }

  Future<double> _overdueCount(
    List<LoanSchedule> schedules,
    List<Loan> loans,
  ) {
    final loanIds =
        loans.where((loan) => loan.fullPaidOn == null).map((loan) => loan.id);
    final total = schedules
        .where((sched) => loanIds.contains(sched.loanId))
        .where(
          (sched) =>
              sched.paidOn == null &&
              Jiffy.parseFromMillisecondsSinceEpoch(sched.date.toInt())
                  .isBefore(Jiffy.now()),
        )
        .length;

    return Future.value(total.toDouble());
  }
}
