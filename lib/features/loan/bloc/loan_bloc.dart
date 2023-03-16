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
import 'package:flutter_mon_loan_tracking/models/lot_category.dart';
import 'package:flutter_mon_loan_tracking/models/payment_status.dart';
import 'package:flutter_mon_loan_tracking/models/settings.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/loan_schedule_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/lot_repository.dart';
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
    required this.lotRepository,
    required this.userRepository,
    required this.settingsRepository,
    required this.authenticationService,
  }) : super(LoanInitial()) {
    // on<LoanEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleSearchLotEvent);
    on(_handleGetSettingsEvent);
    on(_handleAddLoanEvent);
    on(_handleGetAllLoansEvent);
    on(_handleGetAllLotsEvent);
    on(_handleSearchLoanEvent);
    on(_handleFilterByStatusEvent);
    on(_handlePayLoanScheduleEvent);
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

  final num _yearsToPay = 0;

  num _monthlyAmortization = 0;

  num get monthlyAmortization => _monthlyAmortization;

  User? _selectedUser;

  User? get selectedUser => _selectedUser;

  num _outstandingBalance = 0;

  num get outstandingBalance => _outstandingBalance;

  final List<LoanDisplay> _allLoans = [];

  final List<LoanDisplay> _filteredLoans = [];

  List<LoanDisplay> get filteredLoans => _filteredLoans;

  final Map<String, Loan> _loans = {};

  final Map<String, Lot> _mappedLots = {};

  Map<String, Lot> get mappedLots => _mappedLots;

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

    _selectedLot = null;
    _blockNo = null;
    _lotNo = null;
    _discounts.clear();
    _loans.clear();
    _selectedLoan = null;
    _clientLoanSchedules.clear();
    _selectedUser = null;
    _monthlyAmortization = 0;
    _nextPageCalled = null;
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

  void initialize() {
    getSettings();
    getAllLots();
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
    required String date,
    String? incidentalFeeRate,
    String? loanInterestRate,
  }) {
    try {
      if (incidentalFeeRate != null && loanInterestRate != null) {
        add(
          AddLoanEvent(
            downPayment: num.parse(downPayment),
            yearsToPay: num.parse(yearsToPay),
            date: date,
            incidentalFeeRate: num.parse(incidentalFeeRate),
            loanInterestRate: num.parse(loanInterestRate),
            assistingAgent: 'None',
            storeInDb: false,
            withUser: false,
          ),
        );
      } else {
        add(
          AddLoanEvent(
            downPayment: num.parse(downPayment),
            yearsToPay: num.parse(yearsToPay),
            date: date,
            assistingAgent: 'None',
            storeInDb: false,
            withUser: false,
          ),
        );
      }
    } catch (err) {
      printd(err);
    }
  }

  void addLoan(
      {required String yearsToPay,
      required String downPayment,
      required String agentAssisted,
      required String date}) {
    try {
      add(
        AddLoanEvent(
          downPayment: num.parse(downPayment),
          yearsToPay: num.parse(yearsToPay),
          assistingAgent: agentAssisted,
          date: date,
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

  void payLoanSchedule({required LoanSchedule schedule}) {
    add(PayLoanScheduleEvent(schedule: schedule));
  }

  void selectDate({required DateTime date}) {
    emit(LoanSuccessState(message: 'Successfully selected date'));
  }

  num computeTCP({bool throwError = false}) {
    if (selectedLot == null || settings == null) {
      return 0;
    }

    final lotCategory = settings!.lotCategories.firstWhereOrNull(
      (category) => category.key == selectedLot!.lotCategoryKey,
    );

    if (lotCategory == null) {
      printd('Lot category not found');

      if (throwError) {
        throw Exception('Lot category not found');
      }

      return 0;
    }

    return selectedLot!.area * lotCategory.ratePerSquareMeter;
  }

  num computeIncidentalFee({String? customIncidentalFeeRateStr}) {
    if (selectedLot == null || settings == null) {
      return 0;
    }

    final lotCategory = settings!.lotCategories.firstWhereOrNull(
      (category) => category.key == selectedLot!.lotCategoryKey,
    );

    if (lotCategory == null) {
      printd('Lot category not found');
      return 0;
    }

    var tcp = computeTCP();

    if (tcp >= settings!.vattableTCP) {
      tcp += getVatAmount() ?? 0;
    }

    num? customIncidentalFeeRate;

    try {
      customIncidentalFeeRate = num.parse(customIncidentalFeeRateStr ?? '');
    } catch (err) {
      printd('customIncidentalFeeRateStr parse exception: $err');
    }

    final incidentalFeeRate =
        customIncidentalFeeRate ?? settings!.incidentalFeeRate;

    return tcp * (incidentalFeeRate / 100);
  }

  num computeDownPaymentRate({String? customDownpaymenRateStr}) {
    if (selectedLot == null || settings == null) {
      return 0;
    }
    var tcp = computeTCP();

    if (tcp >= settings!.vattableTCP) {
      tcp += getVatAmount() ?? 0;
    }

    num? customDownpaymenRate;

    try {
      if (customDownpaymenRateStr != null) {
        customDownpaymenRate = num.parse(customDownpaymenRateStr);
      }
    } catch (err) {
      printd('probably a parse exception');
    }

    final downpaymentRate = customDownpaymenRate ?? settings!.downPaymentRate;
    final downPaymentRatePercentage = downpaymentRate / 100;

    return tcp * downPaymentRatePercentage;
  }

  num getServiceFee() {
    if (settings == null) {
      return 0;
    }

    return settings!.serviceFee;
  }

  num? getVatAmount() {
    if (settings == null) {
      return null;
    }

    var tcp = computeTCP();

    if (tcp >= settings!.vattableTCP) {
      final vatRatePercent = settings!.vatRate / 100;

      return tcp * vatRatePercent;
    }

    return null;
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
  ///
  /// if totalContractPrice is more than vattableTCP, it should contain
  /// VAT
  void _calculateLoan(
      {required num totalContractPrice,
      required num downPayment,
      required num yearsToPay,
      required String lotCategoryKey,
      required DateTime date,
      required num loanInterestRate,
      required num incidentalFeeRate,
      required LotCategory lotCategory,
      required num serviceFee}) {
    _clientLoanSchedules.clear();

    var outstandingBalance = totalContractPrice;
    // var annualInterestRate = settings!.loanInterestRate / 100;
    var annualInterestRate = loanInterestRate / 100;

    var totalDiscount = downPayment;

    for (final discount in discounts) {
      totalDiscount += discount.discount;
    }
    outstandingBalance -= totalDiscount;
    _outstandingBalance = outstandingBalance;
    // var incidentalFeeRate = _settings!.incidentalFeeRate / 100;
    var computedIncidentalFeeRate = incidentalFeeRate / 100;
    var monthsToPay = yearsToPay * 12;
    // TODO: uncomment when all loans are inputted
    // final incidentalFee = (totalContractPrice * incidentalFeeRate) + serviceFee;
    final incidentalFee = totalContractPrice * computedIncidentalFeeRate;
    // TODO: uncomment when all loans are inputted
    // final monthlyIncidentalFee = (incidentalFee + serviceFee) / monthsToPay;
    final monthlyIncidentalFee = incidentalFee / monthsToPay;
    // printd('incidentalFee + serviceFee = ${incidentalFee + serviceFee}');

    final loanMonthlyAmortization = _calculateMonthlyPayment(
      outstandingBalance: outstandingBalance,
      annualInterestRate: annualInterestRate,
      yearsToPay: yearsToPay,
    );
    _monthlyAmortization = loanMonthlyAmortization + monthlyIncidentalFee;
    var monthlyInterestRate = annualInterestRate / 12;
    printd('starting outstanding balance: $outstandingBalance');
    // var nextMonthDate = date.add(const Duration(days: 30));
    var nextMonthDate =
        Jiffy.unixFromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
            .add(months: 1);
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
        date: nextMonthDate.valueOf(),
        outstandingBalance: outstandingBalance,
        monthlyAmortization: loanMonthlyAmortization + monthlyIncidentalFee,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        incidentalFee: monthlyIncidentalFee,
        loanId: 'loanId:$i',
      );
      _clientLoanSchedules.add(schedule);
      nextMonthDate = nextMonthDate.add(months: 1);
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

      if (_selectedLot == null) {
        emit(LoanErrorState(message: 'Please select block and lot number'));
        return;
      }

      if (_settings == null) {
        emit(LoanErrorState(message: 'Please refresh page'));
        return;
      }
      emit(LoanLoadingState(isLoading: true));

      final lotCategory = settings!.lotCategories.firstWhereOrNull(
        (category) => category.key == selectedLot!.lotCategoryKey,
      );

      if (lotCategory == null) {
        throw Exception('Lot category not found');
      }

      var totalContractPrice = computeTCP(throwError: true);
      num vatValue = 0;

      if (totalContractPrice >= settings!.vattableTCP) {
        final vatRatePercent = settings!.vatRate / 100;
        vatValue = totalContractPrice * vatRatePercent;
      }

      totalContractPrice += vatValue;

      // TODO: uncomment when all loans are inputted
      // TODO: uncomment when serviceFee is implemented
      // final serviceFee = settings!.serviceFee;
      final serviceFee = 0;
      final incidentalFeeRate =
          event.incidentalFeeRate ?? settings!.incidentalFeeRate;

      _calculateLoan(
        totalContractPrice: totalContractPrice,
        downPayment: event.downPayment,
        yearsToPay: event.yearsToPay,
        lotCategoryKey: _selectedLot!.lotCategoryKey,
        date: Constants.defaultDateFormat.parse(event.date),
        incidentalFeeRate: incidentalFeeRate,
        loanInterestRate: event.loanInterestRate ?? settings!.loanInterestRate,
        lotCategory: lotCategory,
        serviceFee: serviceFee,
      );

      var computedIncidentalFeeRate = incidentalFeeRate / 100;
      // TODO: uncomment when all loans are inputted
      // TODO: uncomment when serviceFee is implemented
      // final incidentalFee = (totalContractPrice * incidentalFeeRate) + serviceFee;
      final incidentalFee = totalContractPrice * computedIncidentalFeeRate;
      final loan = Loan.create(
        clientId: clientId,
        preparedBy: authenticationService.loggedInUser!.uid,
        lotId: _selectedLot!.id,
        loanInterestRate: _settings!.loanInterestRate,
        incidentalFeeRate: _settings!.incidentalFeeRate,
        serviceFee: serviceFee,
        perSquareMeterRate: lotCategory.ratePerSquareMeter,
        outstandingBalance: outstandingBalance,
        totalContractPrice: totalContractPrice,
        incidentalFees: incidentalFee,
        downPayment: event.downPayment,
        yearsToPay: event.yearsToPay,
        deductions: _discounts,
        assistingAgent: event.assistingAgent,
        lotCategoryName: lotCategory.name,
        downPaymentRate: settings!.downPaymentRate,
        vatRate: settings!.vatRate,
        vatValue: vatValue,
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
        _selectedLot!.reservedTo = _selectedUser!.id;

        await lotRepository.update(data: _selectedLot!);
        emit(LoanLoadingState());
        emit(LoanSuccessState(message: 'Adding loan successfully'));
        await Future.delayed(const Duration(seconds: 3));
        emit(CloseAddLoanState());
        // clear discounts once loan is been added
        _discounts.clear();
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

        final lots = await lotRepository.all();
        _selectedLot =
            lots.firstWhereOrNull((lot) => lot.id == _selectedLoan!.lotId);

        final futureClientLoanSchedules = clientLoans.map(
          (loan) => loanScheduleRepository.allByLoanId(loanId: loan.id),
        );

        final schedules = await Future.wait(futureClientLoanSchedules)
            .then((value) => value.flattened.toList());
        _clientLoanSchedules
          ..clear()
          ..addAll(schedules.sortedBy((schedule) => schedule.date).toList());
        _allLoans
          ..clear()
          ..addAll(
            clientLoans
                .map((clientLoan) => _clientLoanSchedules
                    .where((schedule) => schedule.loanId == clientLoan.id)
                    .map((schedule) => LoanDisplay(
                        loan: clientLoan,
                        schedule: schedule,
                        lot: _mappedLots[clientLoan.lotId]!)))
                .flattened
                .toList(),
          );
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

          final display = LoanDisplay(
              loan: loan, schedule: schedule, lot: _mappedLots[loan.lotId]!);
          _allLoans.add(display);
          _filteredLoans.add(display);
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
