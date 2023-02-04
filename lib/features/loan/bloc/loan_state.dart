part of 'loan_bloc.dart';

@immutable
abstract class LoanState {}

class LoanInitial extends LoanState {}

class LoanSuccessState extends LoanState {
  final String message;

  LoanSuccessState({ required this.message });
}

class LoanErrorState extends LoanState {
  final String message;

  LoanErrorState({ required this.message });
}

class LoanLoadingState extends LoanState {
  final bool isLoading;
  final String? message;

  LoanLoadingState({ this.isLoading = false, this.message });
}
