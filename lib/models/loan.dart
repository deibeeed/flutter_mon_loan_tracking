import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/discount.dart';
import 'package:flutter_mon_loan_tracking/models/loan_status.dart';
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

  /// serviceFee is defaulted to zero because there
  /// was no service fee implemented in the past.
  @JsonKey(defaultValue: 0)
  final num serviceFee;
  final num createdAt;
  final num ratePerSquareMeter;

  /// all deductions from tcp.
  /// deductions are amounts to deduct
  final List<Discount> deductions;

  /// computed when everything from the
  /// tcp is deducted
  final num outstandingBalance;

  /// tcp = lot area * per sqm rate
  /// if TCP >= Constants.vattableTCP
  /// tcp += vatValue
  final num totalContractPrice;

  /// amount of additional fees.
  /// computed as = tcp * incidentalFeeRate
  /// TODO: add serviceFee in the computation
  /// of incidental fee.
  /// Computation from then should be:
  /// incidentalFee = (tcp * incidentalFeeRate) + serviceFee
  final num incidentalFees;
  final num downPayment;
  final num yearsToPay;
  final String? assistingAgent;
  final String lotCategoryName;
  @JsonKey(defaultValue: 20)
  final num downPaymentRate;
  @JsonKey(defaultValue: 12)
  final num vatRate;

  /// by default vatValue is null.
  /// vatValue will only have value is TCP is
  /// 1.5M pesos or more.
  final num? vatValue;

  @JsonKey(
    defaultValue: null,
  )
  final num? deletedAt;

  Loan({
    required this.id,
    required this.clientId,
    required this.preparedBy,
    required this.lotId,
    required this.loanInterestRate,
    required this.incidentalFeeRate,
    required this.serviceFee,
    required this.createdAt,
    required this.ratePerSquareMeter,
    required this.outstandingBalance,
    required this.totalContractPrice,
    this.deductions = const [],
    required this.incidentalFees,
    required this.downPayment,
    required this.yearsToPay,
    this.assistingAgent,
    required this.lotCategoryName,
    required this.downPaymentRate,
    required this.vatRate,
    this.vatValue,
    this.deletedAt,
  });

  factory Loan.create({
    required String clientId,
    required String preparedBy,
    required String lotId,
    required num loanInterestRate,
    required num incidentalFeeRate,
    required num serviceFee,
    required num perSquareMeterRate,
    required num outstandingBalance,
    required num totalContractPrice,
    required num incidentalFees,
    required num downPayment,
    required num yearsToPay,
    required List<Discount> deductions,
    String? assistingAgent,
    required String lotCategoryName,
    required num downPaymentRate,
    required num vatRate,
    num? vatValue,
  }) =>
      Loan(
        id: Constants.NO_ID,
        clientId: clientId,
        preparedBy: preparedBy,
        lotId: lotId,
        loanInterestRate: loanInterestRate,
        incidentalFeeRate: incidentalFeeRate,
        serviceFee: serviceFee,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        ratePerSquareMeter: perSquareMeterRate,
        incidentalFees: incidentalFees,
        outstandingBalance: outstandingBalance,
        totalContractPrice: totalContractPrice,
        downPayment: downPayment,
        yearsToPay: yearsToPay,
        deductions: deductions,
        assistingAgent: assistingAgent,
        lotCategoryName: lotCategoryName,
        downPaymentRate: downPaymentRate,
        vatRate: vatRate,
        vatValue: vatValue,
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
        serviceFee: loan.serviceFee,
        createdAt: loan.createdAt,
        ratePerSquareMeter: loan.ratePerSquareMeter,
        incidentalFees: loan.incidentalFees,
        outstandingBalance: loan.outstandingBalance,
        totalContractPrice: loan.totalContractPrice,
        downPayment: loan.downPayment,
        yearsToPay: loan.yearsToPay,
        deductions: loan.deductions,
        assistingAgent: loan.assistingAgent,
        lotCategoryName: loan.lotCategoryName,
        downPaymentRate: loan.downPaymentRate,
        vatRate: loan.vatRate,
        vatValue: loan.vatValue,
        deletedAt: loan.deletedAt,
      );

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);

  Map<String, dynamic> toJson() => _$LoanToJson(this);

  @override
  List<Object?> get props => [
        incidentalFees,
        downPayment,
        yearsToPay,
        assistingAgent,
        lotCategoryName,
        downPaymentRate,
        id,
        clientId,
        preparedBy,
        lotId,
        loanInterestRate,
        incidentalFeeRate,
        serviceFee,
        createdAt,
        ratePerSquareMeter,
        deductions,
        outstandingBalance,
        totalContractPrice,
        vatRate,
        vatValue,
        deletedAt,
      ];
}
