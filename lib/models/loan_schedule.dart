import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'loan_schedule.g.dart';

@JsonSerializable()
class LoanSchedule extends Equatable {
  final num date;
  final num outstandingBalance;
  final num monthlyAmortization;
  final num principalPayment;
  final num interestPayment;
  final num incidentalFee;
  num? paidOn;
  final String loanId;
  final String id;
  final num createdAt;

  LoanSchedule({
    required this.date,
    required this.outstandingBalance,
    required this.monthlyAmortization,
    required this.principalPayment,
    required this.interestPayment,
    required this.incidentalFee,
    required this.loanId,
    required this.id,
    required this.createdAt,
  });

  factory LoanSchedule.create({
    required num date,
    required num outstandingBalance,
    required num monthlyAmortization,
    required num principalPayment,
    required num interestPayment,
    required num incidentalFee,
    required String loanId,
  }) =>
      LoanSchedule(
        date: date,
        outstandingBalance: outstandingBalance,
        monthlyAmortization: monthlyAmortization,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        incidentalFee: incidentalFee,
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
        outstandingBalance: loanSchedule.outstandingBalance,
        monthlyAmortization: loanSchedule.monthlyAmortization,
        principalPayment: loanSchedule.principalPayment,
        interestPayment: loanSchedule.interestPayment,
        incidentalFee: loanSchedule.incidentalFee,
        loanId: loanSchedule.loanId,
        id: id,
        createdAt: loanSchedule.createdAt,
      );

  factory LoanSchedule.setLoanId({
    required String loanId,
    required LoanSchedule loanSchedule,
  }) =>
      LoanSchedule(
        date: loanSchedule.date,
        outstandingBalance: loanSchedule.outstandingBalance,
        monthlyAmortization: loanSchedule.monthlyAmortization,
        principalPayment: loanSchedule.principalPayment,
        interestPayment: loanSchedule.interestPayment,
        incidentalFee: loanSchedule.incidentalFee,
        loanId: loanId,
        id: loanSchedule.id,
        createdAt: loanSchedule.createdAt,
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
        incidentalFee,
        paidOn,
        loanId,
        id,
        createdAt,
      ];
}
