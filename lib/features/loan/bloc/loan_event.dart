part of 'loan_bloc.dart';

@immutable
abstract class LoanEvent {}

class CalculateLoanEvent extends LoanEvent { }