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

  LoanSuccessState({ required this.message, this.data });

  @override
  List<Object?> get props => [
    message,
    data
  ];
}

class LoanErrorState extends LoanState {
  final String message;

  LoanErrorState({ required this.message });

  @override
  List<Object?> get props => [
    this.message
  ];
}

class LoanLoadingState extends LoanState {
  final bool isLoading;
  final String? message;

  LoanLoadingState({ this.isLoading = false, this.message });

  @override
  List<Object?> get props => [
    this.isLoading,
    this.message
  ];
}

class CloseAddLoanState extends LoanState {
  @override
  List<Object?> get props => [];

}
