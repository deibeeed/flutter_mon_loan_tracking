import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/discount.dart';
import 'package:flutter_mon_loan_tracking/models/payment_frequency.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'loan.g.dart';

@JsonSerializable()
class Loan extends Equatable {
  final String id;
  final String clientId;
  final String preparedBy;
  final num monthlyInterestRate;
  final num createdAt;
  final num amount;
  final num monthsToPay;
  final double monthlyAmortization;
  final PaymentFrequency paymentFrequency;
  final num startAt;

  Loan({
    required this.id,
    required this.clientId,
    required this.preparedBy,
    required this.monthlyInterestRate,
    required this.createdAt,
    required this.amount,
    required this.monthsToPay,
    required this.monthlyAmortization,
    required this.paymentFrequency,
    required this.startAt,
  });

  factory Loan.create({
    required String clientId,
    required String preparedBy,
    required num interestRate,
    required num amount,
    required num monthsToPay,
    required double monthlyAmortization,
    required PaymentFrequency paymentFrequency,
    required num startAt,
  }) =>
      Loan(
        id: Constants.NO_ID,
        clientId: clientId,
        preparedBy: preparedBy,
        monthlyInterestRate: interestRate,
        createdAt: DateTime.timestamp().millisecondsSinceEpoch,
        amount: amount,
        monthsToPay: monthsToPay,
        monthlyAmortization: monthlyAmortization,
        paymentFrequency: paymentFrequency,
        startAt: startAt,
      );

  factory Loan.updateId({
    required String id,
    required Loan loan,
  }) =>
      Loan(
        id: id,
        clientId: loan.clientId,
        preparedBy: loan.preparedBy,
        monthlyInterestRate: loan.monthlyInterestRate,
        createdAt: loan.createdAt,
        amount: loan.amount,
        monthsToPay: loan.monthsToPay,
        monthlyAmortization: loan.monthlyAmortization,
        paymentFrequency: loan.paymentFrequency,
        startAt: loan.startAt,
      );

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);

  Map<String, dynamic> toJson() => _$LoanToJson(this);

  @override
  List<Object?> get props => [
    monthsToPay,
    id,
    clientId,
    preparedBy,
    monthlyInterestRate,
    createdAt,
    amount,
    monthlyAmortization,
    paymentFrequency,
    startAt,
  ];
}
