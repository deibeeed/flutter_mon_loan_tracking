// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Loan _$LoanFromJson(Map<String, dynamic> json) => Loan(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      preparedBy: json['preparedBy'] as String,
      loanInterestRate: json['loanInterestRate'] as num,
      createdAt: json['createdAt'] as num,
      amount: json['amount'] as num,
      monthsToPay: json['monthsToPay'] as num,
    );

Map<String, dynamic> _$LoanToJson(Loan instance) => <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'preparedBy': instance.preparedBy,
      'loanInterestRate': instance.loanInterestRate,
      'createdAt': instance.createdAt,
      'amount': instance.amount,
      'monthsToPay': instance.monthsToPay,
    };
