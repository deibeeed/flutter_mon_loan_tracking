import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'loan_schedule.g.dart';

@JsonSerializable()
class LoanSchedule extends Equatable {
  final num date;
  final num beginningBalance;
  num outstandingBalance;
  final num monthlyAmortization;
  final num principalPayment;
  final num interestPayment;
  num? paidOn;
  final String loanId;
  final String id;
  final num createdAt;
  num? extraPayment;

  LoanSchedule({
    required this.date,
    required this.beginningBalance,
    required this.outstandingBalance,
    required this.monthlyAmortization,
    required this.principalPayment,
    required this.interestPayment,
    required this.loanId,
    required this.id,
    required this.createdAt,
    this.extraPayment,
  });

  factory LoanSchedule.create({
    required num date,
    required num beginningBalance,
    required num outstandingBalance,
    required num monthlyAmortization,
    required num principalPayment,
    required num interestPayment,
    required String loanId,
  }) =>
      LoanSchedule(
        date: date,
        beginningBalance: beginningBalance,
        outstandingBalance: outstandingBalance,
        monthlyAmortization: monthlyAmortization,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        loanId: loanId,
        id: Constants.NO_ID,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

  factory LoanSchedule.updateId({
    required String id,
    required LoanSchedule loanSchedule,
  }) =>
      LoanSchedule(
        date: loanSchedule.date,
        beginningBalance: loanSchedule.beginningBalance,
        outstandingBalance: loanSchedule.outstandingBalance,
        monthlyAmortization: loanSchedule.monthlyAmortization,
        principalPayment: loanSchedule.principalPayment,
        interestPayment: loanSchedule.interestPayment,
        loanId: loanSchedule.loanId,
        id: id,
        createdAt: loanSchedule.createdAt,
        extraPayment: loanSchedule.extraPayment,
      );

  factory LoanSchedule.setLoanId({
    required String loanId,
    required LoanSchedule loanSchedule,
  }) =>
      LoanSchedule(
        date: loanSchedule.date,
        beginningBalance: loanSchedule.beginningBalance,
        outstandingBalance: loanSchedule.outstandingBalance,
        monthlyAmortization: loanSchedule.monthlyAmortization,
        principalPayment: loanSchedule.principalPayment,
        interestPayment: loanSchedule.interestPayment,
        loanId: loanId,
        id: loanSchedule.id,
        createdAt: loanSchedule.createdAt,
        extraPayment: loanSchedule.extraPayment,
      );

  factory LoanSchedule.fromJson(Map<String, dynamic> json) =>
      _$LoanScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$LoanScheduleToJson(this);

  @override
  List<Object?> get props => [
        date,
        outstandingBalance,
        monthlyAmortization,
        principalPayment,
        interestPayment,
        paidOn,
        loanId,
        id,
        createdAt,
      ];
}
