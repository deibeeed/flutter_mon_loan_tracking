import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_schedule_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/lot_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/settings_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:meta/meta.dart';

part 'loan_event.dart';

part 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  LoanBloc({
    required this.loanRepository,
    required this.loanScheduleRepository,
    required this.lotRepository,
    required this.userRepository,
    required this.settingsRepository,
  }) : super(LoanInitial()) {
    // on<LoanEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleCalculateLoanEvent);
  }

  final LoanRepository loanRepository;
  final LoanScheduleRepository loanScheduleRepository;
  final LotRepository lotRepository;
  final UserRepository userRepository;
  final SettingsRepository settingsRepository;

  final List<LoanSchedule> _clientLoanSchedules = [];

  List<LoanSchedule> get clientLoanSchedules => _clientLoanSchedules;

  void calculateLoan() {
    add(CalculateLoanEvent());
  }

  /// loan computation formula found here:
  /// https://www.mymove.com/mortgage/mortgage-calculation/#:~:text=These%20factors%20include%20the%20total
  Future<void> _handleCalculateLoanEvent(
      CalculateLoanEvent event, Emitter<LoanState> emit) async {
    try {
      emit(LoanLoadingState(isLoading: true));
      // calculate here
      // _clientLoanSchedules.add(LoanSchedule.create(
      //     date: DateTime.now().millisecondsSinceEpoch,
      //     outstandingBalance: outstandingBalance,
      //     monthlyAmortization: monthlyAmortization,
      //     principalPayment: principalPayment,
      //     interestPayment: interestPayment,
      //     incidentalFee: incidentalFee,
      //     loanId: loanId));

      var outstandingBalance = 789192.00;
      const annualInterestRate = 0.045;
      const monthsToPay = 36;

      var monthly = _calculateMonthlyPayment(
        outstandingBalance: outstandingBalance,
        annualInterestRate: 0.045,
        yearsToPay: 3,
      );
      const monthlyInterestRate = annualInterestRate / 12;
      printd('starting outstanding balance: $outstandingBalance');
      const List<LoanSchedule> tmpLoanSchedules = [];
      var currentDate = DateTime.now();
      printd('---------------------------------------------------');
      for (var i = 1; i <= monthsToPay; i++) {
        var interestPayment = outstandingBalance * monthlyInterestRate;
        var principalPayment = monthly - interestPayment;
        outstandingBalance -= principalPayment;
        printd('month: $i');
        printd('monthly: $monthly');
        printd('interestPayment: $interestPayment');
        printd('principalPayment: $principalPayment');
        printd('outstandingBalance: $outstandingBalance');
        printd('---------------------------------------------------');
        LoanSchedule.create(
            date: currentDate.millisecondsSinceEpoch,
            outstandingBalance: outstandingBalance,
            monthlyAmortization: monthlyAmortization,
            principalPayment: principalPayment,
            interestPayment: interestPayment,
            incidentalFee: incidentalFee,
            loanId: loanId);
      }

      emit(LoanLoadingState());
      emit(LoanSuccessState(message: 'Successfully calculated loan'));
    } catch (err) {
      printd(err);
      emit(LoanErrorState(
          message: 'Something went wrong when calculating loan'));
    }
  }

  /// M = P [ i(1 + i)^n ] / [ (1 + i)^n – 1].
  //
  // Here’s a breakdown of each of the variables:
  //
  //     M = Total monthly payment
  //     P = The total amount of your loan
  //     I = Your interest rate, as a monthly percentage
  //     N = The total amount of months in your timeline for paying
  //     off your mortgage
  num _calculateMonthlyPayment({
    required num outstandingBalance,
    required num annualInterestRate,
    required num yearsToPay,
  }) {
    /// in 1 year, there are 12 months
    final monthlyInterestRate = annualInterestRate / 12;
    final monthsToPay = yearsToPay * 12;
    var added = 1.0 + num.parse(monthlyInterestRate.toStringAsFixed(5));
    printd('added: $added');
    var powered = pow(added, monthsToPay);
    printd('pwered: $powered');
    var innerFirst = powered * monthlyInterestRate;
    printd('innerfirst: $innerFirst');
    var outerSecond = powered - 1;
    printd('outerSecond: $outerSecond');
    // var first = powered * tcp;
    // var second = powered - 1;
    var divided = innerFirst / outerSecond;
    printd('divided: $divided');
    var monthly = outstandingBalance * divided;

    return monthly;
  }
}
