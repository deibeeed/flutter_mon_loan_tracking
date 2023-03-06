part of 'loan_bloc.dart';

@immutable
abstract class LoanEvent {}

class CalculateLoanEvent extends LoanEvent {
  final num downPayment;
  final num yearsToPay;

  CalculateLoanEvent({
    required this.downPayment,
    required this.yearsToPay,
  });
}

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
  final num downPayment;
  final num yearsToPay;
  final String assistingAgent;

  AddLoanEvent({
    required this.downPayment,
    required this.yearsToPay,
    required this.assistingAgent,
  });
}

class GetAllLoansEvent extends LoanEvent {
  final String? clientId;
  final bool clearList;

  GetAllLoansEvent({ this.clientId, this.clearList = false});
}

class GetAllLotsEvent extends LoanEvent {}

class SearchLoanEvent extends LoanEvent {
  final String query;

  SearchLoanEvent({
    required this.query,
  });
}

class FilterByStatusDashboardLoanEvent extends LoanEvent {
  final PaymentStatus status;

  FilterByStatusDashboardLoanEvent({ required this.status });
}

class PayLoanScheduleEvent extends LoanEvent{
  final LoanSchedule schedule;

  PayLoanScheduleEvent({ required this.schedule });
}