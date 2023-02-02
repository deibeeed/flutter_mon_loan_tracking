import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'loan.g.dart';

@JsonSerializable()
class Loan extends Equatable {
  final String id;
  final String clientId;
  final String preparedBy;
  final String lotId;
  final num loanInterestRate;
  final num incidentalFeeRate;
  final num reservationFee;
  final num createdAt;

  Loan({
    required this.id,
    required this.clientId,
    required this.preparedBy,
    required this.lotId,
    required this.loanInterestRate,
    required this.incidentalFeeRate,
    required this.reservationFee,
    required this.createdAt,
  });

  factory Loan.create({
    required String clientId,
    required String preparedBy,
    required String lotId,
    required num loanInterestRate,
    required num incidentalFeeRate,
    required num reservationFee,
  }) =>
      Loan(
        id: Constants.NO_ID,
        clientId: clientId,
        preparedBy: preparedBy,
        lotId: lotId,
        loanInterestRate: loanInterestRate,
        incidentalFeeRate: incidentalFeeRate,
        reservationFee: reservationFee,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

  factory Loan.updateId({
    required String id,
    required Loan loan,
  }) =>
      Loan(
        id: id,
        clientId: loan.clientId,
        preparedBy: loan.preparedBy,
        lotId: loan.lotId,
        loanInterestRate: loan.loanInterestRate,
        incidentalFeeRate: loan.incidentalFeeRate,
        reservationFee: loan.reservationFee,
        createdAt: loan.createdAt,
      );

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);

  Map<String, dynamic> toJson() => _$LoanToJson(this);

  @override
  List<Object?> get props => throw UnimplementedError();
}
