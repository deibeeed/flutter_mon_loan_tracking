import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'loan.g.dart';

/// NOTE: to ask:
/// Is there a way na ma usab ang area sa lot once e.sell na cya?
///
/// fees, interests and rates that are set from settings are duplicated
/// in this object to protect the loan from changing especially if the
/// loan has already started and the changed was made half way thru
/// the loan.
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
  final num perSquareMeterRate;
  /// all deductions from tcp.
  /// deductions are amounts to deduct
  final List<num> deductions;
  /// computed when everything from the
  /// tcp is deducted
  final num outstandingBalance;
  /// tcp = lot area * per sqm rate
  final num totalContractPrice;
  /// amount of additional fees.
  /// computed as = tcp * incidentalFeeRate
  final num incidentalFees;

  Loan({
    required this.id,
    required this.clientId,
    required this.preparedBy,
    required this.lotId,
    required this.loanInterestRate,
    required this.incidentalFeeRate,
    required this.reservationFee,
    required this.createdAt,
    required this.perSquareMeterRate,
    required this.outstandingBalance,
    required this.totalContractPrice,
    this.deductions = const [],
    required this.incidentalFees
  });

  factory Loan.create({
    required String clientId,
    required String preparedBy,
    required String lotId,
    required num loanInterestRate,
    required num incidentalFeeRate,
    required num reservationFee,
    required num perSquareMeterRate,
    required num outstandingBalance,
    required num totalContractPrice,
    required num incidentalFees,
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
        perSquareMeterRate: perSquareMeterRate,
        incidentalFees: incidentalFees,
        outstandingBalance: outstandingBalance,
        totalContractPrice: totalContractPrice,
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
        perSquareMeterRate: loan.perSquareMeterRate,
        incidentalFees: loan.incidentalFees,
        outstandingBalance: loan.outstandingBalance,
        totalContractPrice: loan.totalContractPrice,
      );

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);

  Map<String, dynamic> toJson() => _$LoanToJson(this);

  @override
  List<Object?> get props => throw UnimplementedError();
}
