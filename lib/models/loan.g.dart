// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Loan _$LoanFromJson(Map<String, dynamic> json) => Loan(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      preparedBy: json['preparedBy'] as String,
      monthlyInterestRate: json['monthlyInterestRate'] as num,
      createdAt: json['createdAt'] as num,
      amount: json['amount'] as num,
      monthsToPay: json['monthsToPay'] as num,
      monthlyAmortization: (json['monthlyAmortization'] as num).toDouble(),
      paymentFrequency:
          $enumDecode(_$PaymentFrequencyEnumMap, json['paymentFrequency']),
      startAt: json['startAt'] as num,
      fullPaidOn: json['fullPaidOn'] as num?,
      previousLoanBalance: json['previousLoanBalance'] as num? ?? 0,
    );

Map<String, dynamic> _$LoanToJson(Loan instance) => <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'preparedBy': instance.preparedBy,
      'monthlyInterestRate': instance.monthlyInterestRate,
      'createdAt': instance.createdAt,
      'amount': instance.amount,
      'monthsToPay': instance.monthsToPay,
      'monthlyAmortization': instance.monthlyAmortization,
      'paymentFrequency': _$PaymentFrequencyEnumMap[instance.paymentFrequency]!,
      'startAt': instance.startAt,
      'fullPaidOn': instance.fullPaidOn,
      'previousLoanBalance': instance.previousLoanBalance,
    };

const _$PaymentFrequencyEnumMap = {
  PaymentFrequency.monthly: 'monthly',
  PaymentFrequency.biMonthly: 'biMonthly',
};
