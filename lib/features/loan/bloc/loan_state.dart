part of 'loan_bloc.dart';

@immutable
abstract class LoanState extends Equatable {}

class LoanInitial extends LoanState {
  @override
  List<Object?> get props => [];
}

class LoanSuccessState extends LoanState {
  final String message;
  final dynamic data;

  LoanSuccessState({required this.message, this.data});

  @override
  List<Object?> get props => [message, data, Random().nextInt(9999)];
}

class LoanDisplaySummaryState extends LoanState {
  final int? nextPage;
  final List<LoanDisplay> items;
  final dynamic error;

  LoanDisplaySummaryState(
      {required this.nextPage, required this.items, this.error});

  @override
  List<Object?> get props => [
        nextPage,
        items,
        error,
      ];
}

class LoanErrorState extends LoanState {
  final String message;

  LoanErrorState({required this.message});

  @override
  List<Object?> get props => [this.message];
}

class LoanLoadingState extends LoanState {
  final bool isLoading;
  final String? message;

  LoanLoadingState({this.isLoading = false, this.message});

  @override
  List<Object?> get props => [this.isLoading, this.message];
}

class UserHasOutstandingLoanState extends LoanState {
  final double outstandingBalance;

  UserHasOutstandingLoanState({
    required this.outstandingBalance,
  });

  @override
  List<Object?> get props => [
        outstandingBalance,
      ];
}

class CloseAddLoanState extends LoanState {
  @override
  List<Object?> get props => [];
}

class PrintReloanStatementState extends LoanState {
  final Loan loan;
  final List<LoanSchedule> schedules;

  PrintReloanStatementState({ required this.loan, required this.schedules,});

  @override
  List<Object?> get props => [
    loan,
    schedules,
  ];

}
