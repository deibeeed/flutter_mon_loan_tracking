part of 'loan_bloc.dart';

@immutable
abstract class LoanEvent {}

class SearchLotEvent extends LoanEvent {
  final String blockNo;
  final String lotNo;

  SearchLotEvent({
    required this.blockNo,
    required this.lotNo,
  });
}

class GetSettingsEvent extends LoanEvent {}

class AddLoanEvent extends LoanEvent {
  final num monthsToPay;
  final DateTime date;
  final bool storeInDb;
  final bool withUser;
  final double amount;
  final double? interestRate;
  final PaymentFrequency paymentFrequency;

  AddLoanEvent({
    required this.monthsToPay,
    required this.date,
    this.storeInDb = true,
    this.withUser = true,
    required this.amount,
    this.interestRate,
    this.paymentFrequency = PaymentFrequency.monthly,
  });
}

class GetAllLoansEvent extends LoanEvent {
  final String? clientId;
  final bool clearList;

  GetAllLoansEvent({this.clientId, this.clearList = false});
}

class SearchLoanEvent extends LoanEvent {
  final String query;

  SearchLoanEvent({
    required this.query,
  });
}

class FilterByStatusDashboardLoanEvent extends LoanEvent {
  final PaymentStatus status;

  FilterByStatusDashboardLoanEvent({required this.status});
}

class PayLoanScheduleEvent extends LoanEvent {
  final LoanSchedule schedule;
  final double payment;

  PayLoanScheduleEvent({
    required this.schedule,
    required this.payment,
  });
}

class RemoveLoanEvent extends LoanEvent {}
