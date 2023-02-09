// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Loan _$LoanFromJson(Map<String, dynamic> json) => Loan(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      preparedBy: json['preparedBy'] as String,
      lotId: json['lotId'] as String,
      loanInterestRate: json['loanInterestRate'] as num,
      incidentalFeeRate: json['incidentalFeeRate'] as num,
      reservationFee: json['reservationFee'] as num,
      createdAt: json['createdAt'] as num,
      perSquareMeterRate: json['perSquareMeterRate'] as num,
      outstandingBalance: json['outstandingBalance'] as num,
      totalContractPrice: json['totalContractPrice'] as num,
      deductions: (json['deductions'] as List<dynamic>?)
              ?.map((e) => Discount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      incidentalFees: json['incidentalFees'] as num,
      downPayment: json['downPayment'] as num,
      yearsToPay: json['yearsToPay'] as num,
    );

Map<String, dynamic> _$LoanToJson(Loan instance) => <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'preparedBy': instance.preparedBy,
      'lotId': instance.lotId,
      'loanInterestRate': instance.loanInterestRate,
      'incidentalFeeRate': instance.incidentalFeeRate,
      'reservationFee': instance.reservationFee,
      'createdAt': instance.createdAt,
      'perSquareMeterRate': instance.perSquareMeterRate,
      'deductions': instance.deductions,
      'outstandingBalance': instance.outstandingBalance,
      'totalContractPrice': instance.totalContractPrice,
      'incidentalFees': instance.incidentalFees,
      'downPayment': instance.downPayment,
      'yearsToPay': instance.yearsToPay,
    };
