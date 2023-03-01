import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/discount.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_display.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/lot.dart';
import 'package:flutter_mon_loan_tracking/models/payment_status.dart';
import 'package:flutter_mon_loan_tracking/models/settings.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_schedule_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/lot_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/settings_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
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
    required this.authenticationService,
  }) : super(LoanInitial()) {
    // on<LoanEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleCalculateLoanEvent);
    on(_handleSearchLotEvent);
    on(_handleGetSettingsEvent);
    on(_handleGetAllUsersEvent);
    on(_handleAddLoanEvent);
    on(_handleGetAllLoansEvent);
    on(_handleGetAllLotsEvent);
    on(_handleSearchLoanEvent);
    on(_handleFilterByStatusEvent);
    getAllUsers();
    getAllLots();
    getAllLoans();
    getSettings();
  }

  final LoanRepository loanRepository;
  final LoanScheduleRepository loanScheduleRepository;
  final LotRepository lotRepository;
  final UserRepository userRepository;
  final SettingsRepository settingsRepository;
  final AuthenticationService authenticationService;

  final List<LoanSchedule> _clientLoanSchedules = [];

  List<LoanSchedule> get clientLoanSchedules => _clientLoanSchedules;

  final List<Discount> _discounts = [];

  List<Discount> get discounts => _discounts;

  Settings? _settings;

  Settings? get settings => _settings;

  String? _blockNo;
  String? _lotNo;
  Lot? _selectedLot;

  Lot? get selectedLot => _selectedLot;

  num _yearsToPay = 0;

  num _monthlyAmortization = 0;

  num get monthlyAmortization => _monthlyAmortization;

  List<User> _users = [];

  List<User> get users => _users;

  User? _selectedUser;

  User? get selectedUser => _selectedUser;

  num _outstandingBalance = 0;

  num get outstandingBalance => _outstandingBalance;

  List<LoanDisplay> _allLoans = [];

  List<LoanDisplay> _filteredLoans = [];

  List<LoanDisplay> get filteredLoans => _filteredLoans;

  final Map<String, Loan> _loans = {};

  final Map<String, User> _mappedUsers = {};

  Map<String, User> get mappedUsers => _mappedUsers;

  final Map<String, Lot> _mappedLots = {};

  Map<String, Lot> get mappedLots => _mappedLots;

  bool _loansBottomReached = false;

  bool get loansBottomReached => _loansBottomReached;

  bool _isFilteringByStatus = false;

  Loan? _selectedLoan;

  Loan? get selectedLoan => _selectedLoan;

  void reset() {
    _selectedLot = null;
    _blockNo = null;
    _lotNo = null;
    _discounts.clear();
    _loans.clear();
    _selectedLoan = null;
    _clientLoanSchedules.clear();
    emit(LoanSuccessState(message: 'successfully reset values'));
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

  void getSettings() {
    add(GetSettingsEvent());
  }

  void getAllUsers() {
    add(GetAllUsersEvent());
  }

  void getAllLoans({bool clearList = false, String? clientId}) {
    if (clearList) {
      _allLoans.clear();
      _filteredLoans.clear();
    }
    add(GetAllLoansEvent(clientId: clientId));
  }

  void getAllLots() {
    add(GetAllLotsEvent());
  }

  void selectUser({required User user}) {
    _selectedUser = user;
    emit(LoanSuccessState(message: 'Successfully selected user'));
  }

  void calculateLoan({
    required String yearsToPay,
    required String downPayment,
  }) {
    try {
      add(
        CalculateLoanEvent(
          downPayment: num.parse(downPayment),
          yearsToPay: num.parse(yearsToPay),
        ),
      );
    } catch (err) {
      printd(err);
    }
  }

  void addLoan({
    required String yearsToPay,
    required String downPayment,
  }) {
    try {
      add(
        AddLoanEvent(
          downPayment: num.parse(downPayment),
          yearsToPay: num.parse(yearsToPay),
        ),
      );
    } catch (err) {
      printd(err);
    }
  }

  void addDiscount({required String discount, required String description}) {
    printd('add discount');
    if (discount.isEmpty || description.isEmpty) {
      return;
    }

    _discounts.add(
      Discount(
        discount: num.parse(discount),
        description: description,
      ),
    );
    emit(LoanSuccessState(message: 'Successfully added discount'));
  }

  void removeDiscount({required int position}) {
    _discounts.removeAt(position);
    emit(LoanSuccessState(message: 'Successfully removed discount'));
  }

  void setBlockAndLotNo({required String type, required String no}) {
    if (type == 'blockNo') {
      _blockNo = no;
    } else if (type == 'lotNo') {
      _lotNo = no;
    }

    if (_blockNo != null &&
        _lotNo != null &&
        _blockNo!.isNotEmpty &&
        _lotNo!.isNotEmpty) {
      add(SearchLotEvent(blockNo: _blockNo!, lotNo: _lotNo!));
    }
  }

  num computeTCP() {
    if (selectedLot == null || settings == null) {
      return 0;
    }

    return selectedLot!.area * settings!.perSquareMeterRate;
  }

  num computeIncidentalFee() {
    if (selectedLot == null || settings == null) {
      return 0;
    }

    return (selectedLot!.area * settings!.perSquareMeterRate) *
        (settings!.incidentalFeeRate / 100);
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
  Future<void> _handleCalculateLoanEvent(
      CalculateLoanEvent event, Emitter<LoanState> emit) async {
    try {
      if (_selectedLot == null) {
        emit(LoanErrorState(message: 'Please select block and lot number'));
        return;
      }

      if (_settings == null) {
        emit(LoanErrorState(message: 'Please refresh page'));
        return;
      }

      emit(LoanLoadingState(isLoading: true));
      _calculateLoan(
        downPayment: event.downPayment,
        yearsToPay: event.yearsToPay,
      );

      emit(LoanLoadingState());
      emit(LoanSuccessState(message: 'Successfully calculated loan'));
    } catch (err) {
      printd(err);
      emit(LoanErrorState(
          message: 'Something went wrong when calculating loan'));
    }
  }

  void _calculateLoan({
    required num downPayment,
    required num yearsToPay,
  }) {
    _clientLoanSchedules.clear();
    var totalContractPrice = selectedLot!.area * _settings!.perSquareMeterRate;
    var outstandingBalance = totalContractPrice;
    var annualInterestRate = settings!.loanInterestRate / 100;

    var totalDiscount = downPayment;

    for (final discount in discounts) {
      totalDiscount += discount.discount;
    }
    outstandingBalance -= totalDiscount;
    _outstandingBalance = outstandingBalance;
    var incidentalFeeRate = _settings!.incidentalFeeRate / 100;
    var monthsToPay = yearsToPay * 12;
    final incidentalFee = totalContractPrice * incidentalFeeRate;
    final monthlyIncidentalFee = incidentalFee / monthsToPay;

    final loanMonthlyAmortization = _calculateMonthlyPayment(
      outstandingBalance: outstandingBalance,
      annualInterestRate: annualInterestRate,
      yearsToPay: yearsToPay,
    );
    _monthlyAmortization = loanMonthlyAmortization + monthlyIncidentalFee;
    var monthlyInterestRate = annualInterestRate / 12;
    printd('starting outstanding balance: $outstandingBalance');
    var nextMonthDate = DateTime.now().add(const Duration(days: 30));
    printd('---------------------------------------------------');
    for (var i = 1; i <= monthsToPay; i++) {
      final interestPayment = outstandingBalance * monthlyInterestRate;
      final principalPayment = loanMonthlyAmortization - interestPayment;
      outstandingBalance -= principalPayment;
      printd('month: $i');
      printd('monthly: $loanMonthlyAmortization');
      printd('interestPayment: $interestPayment');
      printd('principalPayment: $principalPayment');
      printd('monthlyIncidentalFee: $monthlyIncidentalFee');
      printd('outstandingBalance: $outstandingBalance');
      printd('---------------------------------------------------');
      final schedule = LoanSchedule.create(
        date: nextMonthDate.millisecondsSinceEpoch,
        outstandingBalance: outstandingBalance,
        monthlyAmortization: loanMonthlyAmortization + monthlyIncidentalFee,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        incidentalFee: monthlyIncidentalFee,
        loanId: 'loanId:$i',
      );
      _clientLoanSchedules.add(schedule);
      nextMonthDate = nextMonthDate.add(const Duration(days: 30));
    }
  }

  Future<void> _handleSearchLotEvent(
      SearchLotEvent event, Emitter<LoanState> emit) async {
    try {
      var lot = _mappedLots.values.firstWhereOrNull(
        (lot) => lot.blockNo == event.blockNo && lot.lotNo == event.lotNo,
      );

      lot ??= await lotRepository.searchLot(blockNo: _blockNo!, lotNo: _lotNo!);
      _selectedLot = lot;

      emit(
        LoanSuccessState(
          message: 'Successfully searched lot',
          data: lot,
        ),
      );
    } catch (err) {
      emit(LoanErrorState(
        message: 'Something went wrong while searching for lot',
      ));
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

  Future<void> _handleGetAllUsersEvent(
      GetAllUsersEvent event, Emitter<LoanState> emit) async {
    try {
      _users = await userRepository.all();
      _mappedUsers.addAll({for (var user in _users) user.id: user});
      emit(LoanSuccessState(message: 'Successfully retrieved all users'));
    } catch (err) {
      printd(err);
      emit(LoanErrorState(
          message: 'Something went wrong while getting all users'));
    }
  }

  Future<void> _handleAddLoanEvent(
      AddLoanEvent event, Emitter<LoanState> emit) async {
    try {
      if (!authenticationService.isLoggedIn()) {
        emit(LoanErrorState(message: 'User not logged in'));
        return;
      }

      if (_selectedUser == null) {
        emit(LoanErrorState(message: 'Please select user'));
        return;
      }

      if (_selectedLot == null) {
        emit(LoanErrorState(message: 'Please select block and lot number'));
        return;
      }

      if (_settings == null) {
        emit(LoanErrorState(message: 'Please refresh page'));
        return;
      }
      emit(LoanLoadingState(isLoading: true));
      _calculateLoan(
        downPayment: event.downPayment,
        yearsToPay: event.yearsToPay,
      );
      var totalContractPrice =
          selectedLot!.area * _settings!.perSquareMeterRate;
      var incidentalFeeRate = _settings!.incidentalFeeRate / 100;
      final incidentalFee = totalContractPrice * incidentalFeeRate;
      final loan = Loan.create(
          clientId: _selectedUser!.id,
          preparedBy: authenticationService.loggedInUser!.uid,
          lotId: _selectedLot!.id,
          loanInterestRate: _settings!.loanInterestRate,
          incidentalFeeRate: _settings!.incidentalFeeRate,
          reservationFee: _settings!.reservationFee,
          perSquareMeterRate: _settings!.perSquareMeterRate,
          outstandingBalance: outstandingBalance,
          totalContractPrice: totalContractPrice,
          incidentalFees: incidentalFee,
          downPayment: event.downPayment,
          yearsToPay: event.yearsToPay,
          deductions: _discounts);
      final loanWithId = await loanRepository.add(data: loan);
      final futureLoanSchedules = _clientLoanSchedules.map(
        (schedule) {
          final loanScheduleWithLoanId = LoanSchedule.setLoanId(
              loanId: loanWithId.id, loanSchedule: schedule);
          return loanScheduleRepository.add(data: loanScheduleWithLoanId);
        },
      ).toList();

      await Future.wait(futureLoanSchedules);
      _selectedLot!.reservedTo = _selectedUser!.id;

      await lotRepository.update(data: _selectedLot!);

      emit(LoanLoadingState());
      emit(LoanSuccessState(message: 'Adding loan successfully'));
      await Future.delayed(const Duration(seconds: 3));
      emit(CloseAddLoanState());
      // clear discounts once loan is been added
      _discounts.clear();
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

        final lots = await lotRepository.all();
        _selectedLot = lots.firstWhereOrNull((lot) => lot.id == _selectedLoan!.lotId);

        final futureClientLoanSchedules = clientLoans.map(
          (loan) => loanScheduleRepository.allByLoanId(loanId: loan.id),
        );

        final schedules = await Future.wait(futureClientLoanSchedules)
            .then((value) => value.flattened);
        _clientLoanSchedules
        ..clear()
        ..addAll(schedules.sortedBy((schedule) => schedule.date).toList());
      } else {
        if (_loans.isEmpty) {
          final loans = await loanRepository.all();
          // adding all loans to the map
          _loans.addAll({for (var loan in loans) loan.id: loan});
        }

        final schedules = await loanScheduleRepository.next();

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

      emit(LoanLoadingState());
      emit(LoanSuccessState(message: 'Successfully retrieved loans'));
    } catch (err) {
      printd(err);
      _loansBottomReached = true;
      emit(LoanErrorState(
          message: 'Something went wrong while getting all loans'));
    }
  }

  Future<void> _handleGetAllLotsEvent(
    GetAllLotsEvent event,
    Emitter<LoanState> emit,
  ) async {
    try {
      emit(LoanLoadingState(isLoading: true));

      final lots = await lotRepository.all();
      _mappedLots.addAll({for (var lot in lots) lot.id: lot});

      emit(LoanLoadingState());
      emit(LoanSuccessState(message: 'Successfully retrieved all lots'));
    } catch (err) {
      printd(err);
      emit(
        LoanErrorState(
          message: 'Something went wrong while getting all lots',
        ),
      );
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
                  email.contains(query);
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
