import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_display.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/payment_frequency.dart';
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
    required int monthsToPay,
    required DateTime date,
    double? interestRate,
    required double amount,
    PaymentFrequency paymentFrequency = PaymentFrequency.monthly,
    bool withUser = false,
  }) {
    try {
      if (interestRate != null) {
        add(
          AddLoanEvent(
            monthsToPay: monthsToPay,
            date: date,
            storeInDb: false,
            withUser: withUser,
            amount: amount,
            interestRate: interestRate,
            paymentFrequency: paymentFrequency,
          ),
        );
      } else {
        add(
          AddLoanEvent(
            monthsToPay: monthsToPay,
            date: date,
            storeInDb: false,
            withUser: withUser,
            amount: amount,
            paymentFrequency: paymentFrequency,
          ),
        );
      }
    } catch (err) {
      printd(err);
    }
  }

  void addLoan({
    required int monthsToPay,
    required DateTime date,
    required double amount,
    PaymentFrequency paymentFrequency = PaymentFrequency.monthly,
    bool isReloan = false,
  }) {
    try {
      add(
        AddLoanEvent(
          monthsToPay: monthsToPay,
          amount: amount,
          date: date,
          paymentFrequency: paymentFrequency,
          forceLoan: isReloan,
        ),
      );
    } catch (err) {
      printd(err);
    }
  }

  void payLoanSchedule({
    required LoanSchedule schedule,
    double payment = 0.0,
  }) {
    add(
      PayLoanScheduleEvent(
        schedule: schedule,
        payment: payment,
      ),
    );
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
    required num monthsToPay,
    required DateTime date,
    required num interestRate,
    required PaymentFrequency paymentFrequency,
    List<LoanSchedule> paidSchedules = const [],
  }) {
    _clientLoanSchedules.clear();
    // making sure that paid schedules are sorted by payment date
    paidSchedules.sortBy((sched) => sched.date);
    var monthlyInterestRate = interestRate / 100;
    var outstandingBalance = amount;
    var numOfPayments = monthsToPay;
    var nextMonthDate = Jiffy.parseFromDateTime(date).startOf(Unit.day);

    num loanMonthlyAmortization = 0;

    if (paidSchedules.isEmpty) {
      loanMonthlyAmortization = _calculateMonthlyPayment(
        outstandingBalance: amount,
        monthlyInterestRate: monthlyInterestRate,
        monthsToPay: monthsToPay,
        paymentFrequency: paymentFrequency,
      );
    } else {
      loanMonthlyAmortization = paidSchedules.first.monthlyAmortization;
      outstandingBalance = paidSchedules.last.outstandingBalance;
      nextMonthDate =
          Jiffy.parseFromMillisecondsSinceEpoch(paidSchedules.last.date.toInt())
              .startOf(Unit.day);
    }

    if (paymentFrequency == PaymentFrequency.biMonthly) {
      // loanMonthlyAmortization /= 2;
      numOfPayments *= 2;
      monthlyInterestRate /= 2;
    }

    if (paidSchedules.isNotEmpty) {
      numOfPayments -= paidSchedules.length;
    }

    print('loan amortization: $loanMonthlyAmortization');

    if (paymentFrequency == PaymentFrequency.monthly) {
      nextMonthDate = nextMonthDate.add(months: 1);
    } else {
      nextMonthDate = nextMonthDate.add(days: 15);
    }

    _monthlyAmortization = loanMonthlyAmortization;

    printd('---------------------------------------------------');
    for (var i = 1; i <= numOfPayments; i++) {
      final beginningBalance = outstandingBalance;
      final interestPayment = outstandingBalance * monthlyInterestRate;
      final monthlyAmortization =
          min(loanMonthlyAmortization, beginningBalance + interestPayment);
      final principalPayment = monthlyAmortization - interestPayment;
      outstandingBalance -= principalPayment;
      printd('month: $i');
      printd('date: ${nextMonthDate.format()}');
      printd('monthly: $monthlyAmortization');
      printd('interestPayment: $interestPayment');
      printd('principalPayment: $principalPayment');
      printd('outstandingBalance: $outstandingBalance');
      printd('beginningBalance: $beginningBalance');
      printd('---------------------------------------------------');
      final schedule = LoanSchedule.create(
        date: nextMonthDate.millisecondsSinceEpoch,
        beginningBalance: beginningBalance,
        outstandingBalance: outstandingBalance,
        monthlyAmortization:
            min(loanMonthlyAmortization, beginningBalance + interestPayment),
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        loanId: 'loanId:$i',
      );

      _clientLoanSchedules.add(schedule);

      if (paymentFrequency == PaymentFrequency.monthly) {
        nextMonthDate = nextMonthDate.add(months: 1);
      } else {
        nextMonthDate = nextMonthDate.add(days: 15);
      }
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

      emit(
        LoanLoadingState(
          isLoading: true,
        ),
      );

      var clientId = 'none';

      if (event.withUser) {
        if (_selectedUser == null) {
          emit(LoanErrorState(message: 'Please select user'));
          return;
        }

        clientId = _selectedUser!.id;
      }

      final loanInterestRate = event.interestRate ?? settings!.loanInterestRate;

      var loanableAmount = event.amount;
      num previousLoanBalance = 0;

      // check if client has existing loan
      final clientLastLoan = await loanRepository.clientLastLoan(clientId);
      LoanSchedule? clientLastLoanSchedule;

      if (clientLastLoan != null) {
        clientLastLoanSchedule =
            await loanScheduleRepository.nextOne(clientLastLoan.id);

        previousLoanBalance = clientLastLoanSchedule.beginningBalance;

        loanableAmount -= previousLoanBalance;
      }

      _calculateLoan(
        amount: loanableAmount,
        monthsToPay: event.monthsToPay,
        date: event.date,
        interestRate: loanInterestRate,
        paymentFrequency: event.paymentFrequency,
      );

      final firstSchedule = _clientLoanSchedules.first;

      final loan = Loan.create(
        clientId: clientId,
        preparedBy: authenticationService.loggedInUser!.uid,
        interestRate: loanInterestRate,
        monthsToPay: event.monthsToPay,
        amount: loanableAmount,
        monthlyAmortization: _monthlyAmortization.toDouble(),
        paymentFrequency: event.paymentFrequency,
        startAt: event.date.millisecondsSinceEpoch,
        previousLoanBalance: previousLoanBalance,
      );

      if (event.storeInDb) {
        if (clientLastLoan != null && !event.forceLoan) {
          emit(LoanLoadingState());
          emit(
            UserHasOutstandingLoanState(
              outstandingBalance: previousLoanBalance.toDouble(),
            ),
          );
          return;
        }

        final loanWithId = await loanRepository.add(data: loan);
        final schedule = await loanScheduleRepository.add(
          data: LoanSchedule.setLoanId(
            loanId: loanWithId.id,
            loanSchedule: firstSchedule,
          ),
        );

        // finish previous loan
        if (clientLastLoan != null) {
          await loanRepository.update(
            data: clientLastLoan
              ..fullPaidOn = event.date.millisecondsSinceEpoch,
          );

          if (clientLastLoanSchedule != null) {
            await loanScheduleRepository.update(
              data: clientLastLoanSchedule
                ..paidOn = event.date.millisecondsSinceEpoch,
            );
          }
        }

        emit(LoanLoadingState());
        emit(LoanSuccessState(message: 'Adding loan successfully'));

        if (clientLastLoan != null) {
          emit(
            PrintReloanStatementState(
              loan: loan,
              schedules: _clientLoanSchedules,
            ),
          );
        } else {
          emit(CloseAddLoanState());
        }
      } else {
        _selectedLoan = loan;
        emit(LoanLoadingState());
        emit(
          LoanSuccessState(
            message: 'compute loan successfully',
            data: loan,
          ),
        );
      }
    } catch (err) {
      printd(err);
      emit(LoanLoadingState());
      emit(LoanErrorState(message: 'Something went wrong while adding loan'));
    }
  }

  var _lastGetAllLoansCalled = 0;

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
        _loans.addAll({for (final loan in clientLoans) loan.id: loan});
        _selectedLoan = clientLoans.firstOrNull;

        if (_selectedLoan == null) {
          throw Exception('Client no loans');
        }

        final futureClientLoanSchedules = clientLoans.map(
          (loan) => loanScheduleRepository.allByLoanId(
            loanId: loan.id,
            onlyPaid: false,
          ),
        );

        final schedules =
            (await Future.wait(futureClientLoanSchedules)).flattened.toList();
        // construct remaining schedules
        if (schedules.isNotEmpty) {
          _calculateLoan(
            amount: _selectedLoan!.amount,
            monthsToPay: _selectedLoan!.monthsToPay,
            date: DateTime.fromMillisecondsSinceEpoch(
                _selectedLoan!.startAt.toInt()),
            interestRate: _selectedLoan!.monthlyInterestRate,
            paymentFrequency: _selectedLoan!.paymentFrequency,
            paidSchedules: schedules,
          );
          _clientLoanSchedules.insertAll(
              0, schedules.sortedBy((schedule) => schedule.date).toList());
          _allLoans
            ..clear()
            ..addAll(
              clientLoans
                  .map(
                    (clientLoan) => _clientLoanSchedules
                        .where((schedule) => schedule.loanId == clientLoan.id)
                        .map(
                          (schedule) => LoanDisplay(
                            loan: clientLoan,
                            schedule: schedule,
                          ),
                        ),
                  )
                  .flattened
                  .toList(),
            );
          _filteredLoans
            ..clear()
            ..addAll(_allLoans);
        }
        _nextPageCalled = null;
      } else {
        final calledNow = Jiffy.now();

        if (calledNow.diff(
                Jiffy.parseFromMillisecondsSinceEpoch(_lastGetAllLoansCalled),
                unit: Unit.millisecond) <
            500) {
          throw Exception('Already called!');
        }

        _lastGetAllLoansCalled = calledNow.millisecondsSinceEpoch;

        if (event.clearList) {
          _allLoans.clear();
          _filteredLoans.clear();
        }

        var loans = <Loan>[];
        if (_loans.isEmpty) {
          loans = await loanRepository.all();
          // adding all loans to the map
          _loans.addAll({for (final loan in loans) loan.id: loan});
        }

        if (_loans.isNotEmpty) {
          final futureClientLoanSchedules = _loans.values.map(
            (loan) => loanScheduleRepository.nextOne(loan.id),
          );

          final schedules = await Future.wait(futureClientLoanSchedules);
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
      emit(
        LoanDisplaySummaryState(
          nextPage: _nextPageCalled,
          items: _filteredLoans..sortBy((key) => key.schedule.date),
        ),
      );
      emit(LoanSuccessState(message: 'Successfully retrieved loans'));
    } catch (err) {
      printd(err);
      _loansBottomReached = true;
      emit(
        LoanDisplaySummaryState(
          error: err,
          nextPage: _nextPageCalled,
          items: _filteredLoans,
        ),
      );
      emit(LoanErrorState(
          message: 'Something went wrong while getting all loans'));
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
      emit(LoanDisplaySummaryState(
        nextPage: 0,
        items: _filteredLoans,
      ));
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
      var nextPageKey = _nextPageCalled;
      switch (event.status) {
        case PaymentStatus.all:
          filteredList.addAll(_allLoans);
          _isFilteringByStatus = false;
          nextPageKey = _nextPageCalled;
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
      emit(
        LoanDisplaySummaryState(
          nextPage: 1,
          items: _filteredLoans,
        ),
      );
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
      final extraPayment = event.payment - schedule.monthlyAmortization;

      if (extraPayment > 0.0) {
        schedule
          ..extraPayment = extraPayment
          ..outstandingBalance -= extraPayment;
      }

      await loanScheduleRepository.update(data: schedule);

      // create next schedule
      final loan = _loans[schedule.loanId];
      if (loan != null) {
        if (schedule.outstandingBalance <= 0) {
          // fully paid!!
          loan.fullPaidOn = DateTime.timestamp().millisecondsSinceEpoch;
          await loanRepository.update(data: loan);
        } else {
          final allSchedules =
              await loanScheduleRepository.allByLoanId(loanId: loan.id);
          _calculateLoan(
            amount: loan.amount,
            monthsToPay: loan.monthsToPay,
            date: DateTime.fromMillisecondsSinceEpoch(loan.startAt.toInt()),
            interestRate: loan.monthlyInterestRate,
            paymentFrequency: loan.paymentFrequency,
            paidSchedules: allSchedules,
          );
          final loanScheduleDate =
              Jiffy.parseFromMillisecondsSinceEpoch(schedule.date.toInt());
          var nextPaymentDate = loanScheduleDate;

          if (loan.paymentFrequency == PaymentFrequency.monthly) {
            nextPaymentDate = loanScheduleDate.add(months: 1);
          } else {
            nextPaymentDate = loanScheduleDate.add(days: 15);
          }

          final nextScheduleTemp = _clientLoanSchedules.firstWhereOrNull(
              (sched) => sched.date == nextPaymentDate.millisecondsSinceEpoch);

          if (nextScheduleTemp != null) {
            final nextSchedule = LoanSchedule.setLoanId(
              loanId: loan.id,
              loanSchedule: nextScheduleTemp,
            );

            await loanScheduleRepository.add(data: nextSchedule);
          }
        }
      }

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
  num _calculateMonthlyPayment({
    required num outstandingBalance,
    required num monthlyInterestRate,
    required num monthsToPay,
    required PaymentFrequency paymentFrequency,
  }) {
    var interestRate = monthlyInterestRate;
    var numPayments = monthsToPay;

    if (paymentFrequency == PaymentFrequency.biMonthly) {
      interestRate /= 2;
      numPayments *= 2;
    }

    num p = (outstandingBalance * interestRate) /
        (1 - pow(1 + interestRate, -1 * numPayments));

    return p;
  }
}
