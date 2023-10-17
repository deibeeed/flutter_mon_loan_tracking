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
      serviceFee: json['serviceFee'] as num? ?? 0,
      createdAt: json['createdAt'] as num,
      ratePerSquareMeter: json['ratePerSquareMeter'] as num,
      outstandingBalance: json['outstandingBalance'] as num,
      totalContractPrice: json['totalContractPrice'] as num,
      deductions: (json['deductions'] as List<dynamic>?)
              ?.map((e) => Discount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      incidentalFees: json['incidentalFees'] as num,
      downPayment: json['downPayment'] as num,
      yearsToPay: json['yearsToPay'] as num,
      assistingAgent: json['assistingAgent'] as String?,
      lotCategoryName: json['lotCategoryName'] as String,
      downPaymentRate: json['downPaymentRate'] as num? ?? 20,
      vatRate: json['vatRate'] as num? ?? 12,
      vatValue: json['vatValue'] as num?,
    );

Map<String, dynamic> _$LoanToJson(Loan instance) => <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'preparedBy': instance.preparedBy,
      'lotId': instance.lotId,
      'loanInterestRate': instance.loanInterestRate,
      'incidentalFeeRate': instance.incidentalFeeRate,
      'serviceFee': instance.serviceFee,
      'createdAt': instance.createdAt,
      'ratePerSquareMeter': instance.ratePerSquareMeter,
      'deductions': instance.deductions.map((e) => e.toJson()).toList(),
      'outstandingBalance': instance.outstandingBalance,
      'totalContractPrice': instance.totalContractPrice,
      'incidentalFees': instance.incidentalFees,
      'downPayment': instance.downPayment,
      'yearsToPay': instance.yearsToPay,
      'assistingAgent': instance.assistingAgent,
      'lotCategoryName': instance.lotCategoryName,
      'downPaymentRate': instance.downPaymentRate,
      'vatRate': instance.vatRate,
      'vatValue': instance.vatValue,
    };
