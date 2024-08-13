import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/discount.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'loan.g.dart';

@JsonSerializable()
class Loan extends Equatable {
  final String id;
  final String clientId;
  final String preparedBy;
  final num loanInterestRate;
  final num createdAt;
  final num amount;
  final num monthsToPay;

  Loan({
    required this.id,
    required this.clientId,
    required this.preparedBy,
    required this.loanInterestRate,
    required this.createdAt,
    required this.amount,
    required this.monthsToPay,
  });

  factory Loan.create({
    required String clientId,
    required String preparedBy,
    required num interestRate,
    required num amount,
    required num yearsToPay,
  }) =>
      Loan(
        id: Constants.NO_ID,
        clientId: clientId,
        preparedBy: preparedBy,
        loanInterestRate: interestRate,
        createdAt: DateTime.timestamp().millisecondsSinceEpoch,
        amount: amount,
        monthsToPay: yearsToPay,
      );

  factory Loan.updateId({
    required String id,
    required Loan loan,
  }) =>
      Loan(
        id: id,
        clientId: loan.clientId,
        preparedBy: loan.preparedBy,
        loanInterestRate: loan.loanInterestRate,
        createdAt: loan.createdAt,
        amount: loan.amount,
        monthsToPay: loan.monthsToPay,
      );

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);

  Map<String, dynamic> toJson() => _$LoanToJson(this);

  @override
  List<Object?> get props => [
    monthsToPay,
    id,
    clientId,
    preparedBy,
    loanInterestRate,
    createdAt,
    amount,
  ];
}
