import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/discount.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_display.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/payment_status.dart';
import 'package:flutter_mon_loan_tracking/models/settings.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_schedule_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/settings_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:jiffy/jiffy.dart';
import 'package:meta/meta.dart';

part 'loan_event.dart';

part 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  LoanBloc({
    required this.loanRepository,
    required this.loanScheduleRepository,
    required this.userRepository,
    required this.settingsRepository,
    required this.authenticationService,
  }) : super(LoanInitial()) {
    on(_handleGetSettingsEvent);
    on(_handleAddLoanEvent);
    on(_handleGetAllLoansEvent);
    on(_handleSearchLoanEvent);
    on(_handleFilterByStatusEvent);
    on(_handlePayLoanScheduleEvent);
    on(_handleRemoveLoanEvent);
    getAllLoans();
    getSettings();
  }

  final LoanRepository loanRepository;
  final LoanScheduleRepository loanScheduleRepository;
  final UserRepository userRepository;
  final SettingsRepository settingsRepository;
  final AuthenticationService authenticationService;

  final List<LoanSchedule> _clientLoanSchedules = [];

  List<LoanSchedule> get clientLoanSchedules => _clientLoanSchedules;

  Settings? _settings;

  Settings? get settings => _settings;

  final num _yearsToPay = 0;

  num _monthlyAmortization = 0;

  num get monthlyAmortization => _monthlyAmortization;

  User? _selectedUser;

  User? get selectedUser => _selectedUser;

  final List<LoanDisplay> _allLoans = [];

  final List<LoanDisplay> _filteredLoans = [];

  List<LoanDisplay> get filteredLoans => _filteredLoans;

  final Map<String, Loan> _loans = {};

  bool _loansBottomReached = false;

  bool get loansBottomReached => _loansBottomReached;

  bool _isFilteringByStatus = false;

  Loan? _selectedLoan;

  Loan? get selectedLoan => _selectedLoan;

  int? _nextPageCalled;

  bool withCustomTCP = false;

  void reset({bool isLogout = false}) {
    if (isLogout) {
      loanScheduleRepository.reset();
      _allLoans.clear();
      _filteredLoans.clear();
    }

    _loans.clear();
    _selectedLoan = null;
    _clientLoanSchedules.clear();
    _selectedUser = null;
    _monthlyAmortization = 0;
    _nextPageCalled = null;
    withCustomTCP = false;
    emit(LoanSuccessState(message: 'successfully reset values'));
  }

  void removeLoan() {
    add(RemoveLoanEvent());
  }

  void search({
    required String query,
  }) {
    add(SearchLoanEvent(query: query));
  }

  void filterByStatus({required String status}) {
    var paymentStatus = PaymentStatus.all;
    switch (status.toLowerCase()) {
      case 'paid':
        paymentStatus = PaymentStatus.paid;
        break;
      case 'overdue':
        paymentStatus = PaymentStatus.overdue;
        break;
    }
    _isFilteringByStatus = true;
    add(FilterByStatusDashboardLoanEvent(status: paymentStatus));
  }

  void initialize() {
    getSettings();
    getAllLoans(clearList: true);
  }

  void getSettings() {
    add(GetSettingsEvent());
  }

  void getAllLoans({bool clearList = false, String? clientId}) {
    if (clearList) {
      _allLoans.clear();
      _filteredLoans.clear();
      _loansBottomReached = false;
      _nextPageCalled = null;
    }
    add(GetAllLoansEvent(clientId: clientId, clearList: clearList));
  }

  void selectUser({required User user}) {
    _selectedUser = user;
    emit(LoanSuccessState(message: 'Successfully selected user'));
  }

  void calculateLoan({
    required String monthsToPay,
    required String date,
    String? loanInterestRate,
    String? amount,
  }) {
    printd('loanInterestRate: $loanInterestRate');
    printd('TCP: $amount');
    num? finalTcp;

    if (amount != null) {
      finalTcp = Constants.defaultCurrencyFormat.parse(amount);
    }

    try {
      if (loanInterestRate != null) {
        add(
          AddLoanEvent(
            yearsToPay: Constants.defaultCurrencyFormat.parse(monthsToPay),
            date: date,
            storeInDb: false,
            withUser: false,
            amount: finalTcp,
          ),
        );
      } else {
        add(
          AddLoanEvent(
            yearsToPay: Constants.defaultCurrencyFormat.parse(monthsToPay),
            date: date,
            storeInDb: false,
            withUser: false,
            amount: finalTcp,
          ),
        );
      }
    } catch (err) {
      printd(err);
    }
  }

  void addLoan({
    required String yearsToPay,
    required String date,
    required String amount,
  }) {
    try {
      add(
        AddLoanEvent(
          yearsToPay: num.parse(yearsToPay),
          amount:
              Constants.defaultCurrencyFormat.parse(amount),
          date: date,
        ),
      );
    } catch (err) {
      printd(err);
    }
  }

  void payLoanSchedule({required LoanSchedule schedule}) {
    add(PayLoanScheduleEvent(schedule: schedule));
  }

  void selectDate({required DateTime date}) {
    emit(LoanSuccessState(message: 'Successfully selected date'));
  }

  num yearsToMonths({required String years}) {
    try {
      return num.parse(years) * 12;
    } catch (err) {
      return 0;
    }
  }

  PaymentStatus getPaymentStatus({required LoanSchedule schedule}) {
    if (schedule.paidOn != null) {
      return PaymentStatus.paid;
    }

    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(schedule.date.toInt());

    if (schedule.paidOn == null && now.isAfter(date)) {
      return PaymentStatus.overdue;
    }

    return PaymentStatus.nextPayment;
  }

  /// PRIVATE METHODS

  /// loan computation formula found here:
  /// https://www.mymove.com/mortgage/mortgage-calculation/#:~:text=These%20factors%20include%20the%20total
  void _calculateLoan({
    required num amount,
    required num yearsToPay,
    required DateTime date,
    required num interestRate,
  }) {
    _clientLoanSchedules.clear();
    var annualInterestRate = interestRate / 100;
    var monthsToPay = yearsToPay * 12;
    var outstandingBalance = amount;

    final loanMonthlyAmortization = _calculateMonthlyPayment2(
      outstandingBalance: amount,
      annualInterestRate: annualInterestRate,
      yearsToPay: yearsToPay,
    );
    _monthlyAmortization = loanMonthlyAmortization;
    var monthlyInterestRate = annualInterestRate / 12;
    // var nextMonthDate = date.add(const Duration(days: 30));
    var nextMonthDate =
        Jiffy.parseFromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
            .add(months: 1);
    printd('---------------------------------------------------');
    for (var i = 1; i <= monthsToPay; i++) {
      final interestPayment = amount * monthlyInterestRate;
      final principalPayment = loanMonthlyAmortization - interestPayment;
      outstandingBalance -= principalPayment;
      printd('month: $i');
      printd('monthly: $loanMonthlyAmortization');
      printd('interestPayment: $interestPayment');
      printd('principalPayment: $principalPayment');
      printd('outstandingBalance: $outstandingBalance');
      printd('---------------------------------------------------');
      final schedule = LoanSchedule.create(
        date: nextMonthDate.millisecondsSinceEpoch,
        outstandingBalance: outstandingBalance,
        monthlyAmortization: loanMonthlyAmortization,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        loanId: 'loanId:$i',
      );
      _clientLoanSchedules.add(schedule);
      nextMonthDate = nextMonthDate.add(months: 1);
    }
  }

  Future<void> _handleGetSettingsEvent(
    GetSettingsEvent event,
    Emitter<LoanState> emit,
  ) async {
    try {
      _settings = await settingsRepository.getLatest();
      emit(LoanSuccessState(message: 'Successfully retrieved latest settings'));
    } catch (err) {
      print(err);
      emit(
        LoanErrorState(
          message: 'Something went wrong while getting settings',
        ),
      );
    }
  }

  Future<void> _handleAddLoanEvent(
      AddLoanEvent event, Emitter<LoanState> emit) async {
    try {
      if (!authenticationService.isLoggedIn()) {
        emit(LoanErrorState(message: 'User not logged in'));
        return;
      }

      var clientId = 'none';

      if (event.withUser) {
        if (_selectedUser == null) {
          emit(LoanErrorState(message: 'Please select user'));
          return;
        }

        clientId = _selectedUser!.id;
      }

      final loanInterestRate = settings!.loanInterestRate;

      _calculateLoan(
        amount: event.amount!,
        yearsToPay: event.yearsToPay,
        date: Constants.defaultDateFormat.parse(event.date),
        interestRate: loanInterestRate,
      );

      final loan = Loan.create(
        clientId: clientId,
        preparedBy: authenticationService.loggedInUser!.uid,
        interestRate: loanInterestRate,
        yearsToPay: event.yearsToPay,
        amount: event.amount!,
      );

      if (event.storeInDb) {
        final loanWithId = await loanRepository.add(data: loan);
        final futureLoanSchedules = _clientLoanSchedules.map(
          (schedule) {
            final loanScheduleWithLoanId = LoanSchedule.setLoanId(
                loanId: loanWithId.id, loanSchedule: schedule);
            return loanScheduleRepository.add(data: loanScheduleWithLoanId);
          },
        ).toList();

        await Future.wait(futureLoanSchedules);
        emit(LoanLoadingState());
        emit(LoanSuccessState(message: 'Adding loan successfully'));
        await Future.delayed(const Duration(seconds: 3));
        emit(CloseAddLoanState());
      } else {
        _selectedLoan = loan;
        emit(LoanLoadingState());
        emit(LoanSuccessState(message: 'compute loan successfully'));
      }
    } catch (err) {
      printd(err);
      emit(LoanLoadingState());
      emit(LoanErrorState(message: 'Something went wrong while adding loan'));
    }
  }

  Future<void> _handleGetAllLoansEvent(
    GetAllLoansEvent event,
    Emitter<LoanState> emit,
  ) async {
    try {
      if (_isFilteringByStatus) return;

      emit(LoanLoadingState(isLoading: true));

      if (event.clientId != null) {
        _loans.clear();
        final loans = await loanRepository.all();
        final clientLoans = loans.where(
          (loan) => loan.clientId == event.clientId,
        );
        _loans.addAll({for (var loan in clientLoans) loan.id: loan});
        _selectedLoan = clientLoans.firstOrNull;

        final futureClientLoanSchedules = clientLoans.map(
          (loan) => loanScheduleRepository.allByLoanId(loanId: loan.id),
        );

        final schedules = await Future.wait(futureClientLoanSchedules)
            .then((value) => value.flattened.toList());
        _clientLoanSchedules
          ..clear()
          ..addAll(schedules.sortedBy((schedule) => schedule.date).toList());
        _allLoans..clear();
        _filteredLoans
          ..clear()
          ..addAll(_allLoans);
        _nextPageCalled = null;
      } else {
        if (_loans.isEmpty) {
          final loans = await loanRepository.all();
          // adding all loans to the map
          _loans.addAll({for (var loan in loans) loan.id: loan});
        }

        if (_loans.isNotEmpty) {
          final schedules =
              await loanScheduleRepository.next(reset: event.clearList);
          _nextPageCalled = _nextPageCalled == null ? 0 : _nextPageCalled! + 1;

          if (schedules.length < Constants.loanScheduleQueryResultLimit) {
            _nextPageCalled = null;
          }

          for (final schedule in schedules) {
            var loan = _loans[schedule.loanId];

            if (loan == null) {
              loan = await loanRepository.get(id: schedule.loanId);
              _loans[loan.id] = loan;
            }

            final display = LoanDisplay(loan: loan, schedule: schedule);
            _allLoans.add(display);
            _filteredLoans.add(display);
          }
        }
      }

      emit(LoanLoadingState());
      emit(LoanDisplaySummaryState(
          nextPage: _nextPageCalled, items: _filteredLoans));
      emit(LoanSuccessState(message: 'Successfully retrieved loans'));
    } catch (err) {
      printd(err);
      _loansBottomReached = true;
      emit(LoanDisplaySummaryState(
          error: err, nextPage: _nextPageCalled, items: _filteredLoans));
      emit(LoanErrorState(
          message: 'Something went wrofng while getting all loans'));
    }
  }

  Future<void> _handleSearchLoanEvent(
    SearchLoanEvent event,
    Emitter<LoanState> emit,
  ) async {
    try {
      emit(LoanLoadingState(isLoading: true));
      final query = event.query;
      if (query.isNotEmpty) {
        final cacheUsers = await userRepository.allCache();
        final userIds = cacheUsers
            .where((user) {
              final firstName = user.firstName.toLowerCase();
              final lastName = user.lastName.toLowerCase();
              final email = user.email;

              return firstName.contains(query) ||
                  lastName.contains(query) ||
                  email?.contains(query) == true;
            })
            .map((user) => user.id)
            .toList();
        final filteredList = _allLoans
            .where(
              (display) => userIds.contains(display.loan.clientId),
            )
            .toList();
        _filteredLoans
          ..clear()
          ..addAll(filteredList);
      } else {
        _filteredLoans
          ..clear()
          ..addAll(_allLoans);
      }

      emit(LoanLoadingState());
      emit(LoanSuccessState(
          message: 'Successfully searched for ${event.query}'));
    } catch (err) {
      printd(err);
      emit(LoanLoadingState());
      emit(
        LoanErrorState(
          message: 'Something went wrong while searching for ${event.query}',
        ),
      );
    }
  }

  Future<void> _handleFilterByStatusEvent(
    FilterByStatusDashboardLoanEvent event,
    Emitter<LoanState> emit,
  ) async {
    try {
      emit(LoanLoadingState(isLoading: true));

      final now = DateTime.now().millisecondsSinceEpoch;
      final filteredList = <LoanDisplay>[];
      switch (event.status) {
        case PaymentStatus.all:
          filteredList.addAll(_allLoans);
          _isFilteringByStatus = false;
          break;
        case PaymentStatus.paid:
          filteredList.addAll(
            _allLoans
                .where((display) => display.schedule.paidOn != null)
                .toList(),
          );
          break;
        case PaymentStatus.overdue:
          filteredList.addAll(
            _allLoans
                .where((display) =>
                    display.schedule.paidOn == null &&
                    display.schedule.date < now)
                .toList(),
          );
          break;
        case PaymentStatus.nextPayment:
          filteredList.addAll(
            _allLoans
                .where((display) =>
                    display.schedule.paidOn == null &&
                    display.schedule.date >= now)
                .toList(),
          );
          break;
      }

      _filteredLoans
        ..clear()
        ..addAll(filteredList);

      emit(LoanLoadingState());
      emit(LoanSuccessState(message: 'Successfully filtered loan schedules'));
    } catch (err) {
      printd(err);
      emit(LoanLoadingState());
      emit(LoanErrorState(
          message: 'Something went wrong while filtering loan schedules'));
    }
  }

  Future<void> _handlePayLoanScheduleEvent(
    PayLoanScheduleEvent event,
    Emitter<LoanState> emit,
  ) async {
    try {
      emit(LoanLoadingState(isLoading: true));
      final schedule = event.schedule
        ..paidOn = DateTime.now().millisecondsSinceEpoch;
      await loanScheduleRepository.update(data: schedule);
      emit(LoanLoadingState());
      emit(LoanSuccessState(message: 'Successfully paid loan schedule'));
    } catch (err) {
      printd(err);
      emit(LoanLoadingState());
      emit(LoanErrorState(
          message: 'Something went wrong while paying schedule'));
    }
  }

  Future<void> _handleRemoveLoanEvent(
    RemoveLoanEvent event,
    Emitter<LoanState> emit,
  ) async {
    try {
      if (_selectedLoan == null) {
        return;
      }

      emit(LoanLoadingState(isLoading: true));

      await loanRepository.delete(data: _selectedLoan!);
      final futures = _clientLoanSchedules
          .map((e) => loanScheduleRepository.delete(data: e));
      await Future.wait(futures);
      _selectedLoan = null;
      _clientLoanSchedules.clear();

      emit(LoanLoadingState());
      emit(LoanSuccessState(message: 'Successfully removed loan'));
    } catch (err) {
      printd('Something went wrong while removing loan: $err');
      emit(LoanLoadingState());
      emit(LoanErrorState(
          message: 'Something went wrong when removing loan: $err'));
    }
  }

  /// P = (Pv*R) / [1 - (1 + R)^(-n)]
  ///
  /// Here’s a breakdown of each of the variables:
  ///
  ///     P = Monthly Payment
  ///     Pv = Present Value (starting value of the loan)
  ///     APR = Annual Percentage Rate
  ///     R = Periodic Interest Rate = APR/number of interest periods per year
  ///     n = Total number of interest periods (interest periods per year * number of years)
  ///
  /// source: https://superuser.com/questions/871404/what-would-be-the-the-mathematical-equivalent-of-this-excel-formula-pmt
  num _calculateMonthlyPayment2({
    required num outstandingBalance,
    required num annualInterestRate,
    required num yearsToPay,
  }) {
    /// in 1 year, there are 12 months
    final monthlyInterestRate = annualInterestRate / 12;
    final monthsToPay = yearsToPay * 12;

    num p = (outstandingBalance * monthlyInterestRate) /
        (1 - pow(1 + monthlyInterestRate, -1 * monthsToPay));

    return p;
  }
}
