// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoanSchedule _$LoanScheduleFromJson(Map<String, dynamic> json) => LoanSchedule(
      date: json['date'] as num,
      beginningBalance: json['beginningBalance'] as num,
      outstandingBalance: json['outstandingBalance'] as num,
      monthlyAmortization: json['monthlyAmortization'] as num,
      principalPayment: json['principalPayment'] as num,
      interestPayment: json['interestPayment'] as num,
      loanId: json['loanId'] as String,
      id: json['id'] as String,
      createdAt: json['createdAt'] as num,
      extraPayment: json['extraPayment'] as num?,
    )..paidOn = json['paidOn'] as num?;

Map<String, dynamic> _$LoanScheduleToJson(LoanSchedule instance) =>
    <String, dynamic>{
      'date': instance.date,
      'beginningBalance': instance.beginningBalance,
      'outstandingBalance': instance.outstandingBalance,
      'monthlyAmortization': instance.monthlyAmortization,
      'principalPayment': instance.principalPayment,
      'interestPayment': instance.interestPayment,
      'paidOn': instance.paidOn,
      'loanId': instance.loanId,
      'id': instance.id,
      'createdAt': instance.createdAt,
      'extraPayment': instance.extraPayment,
    };
