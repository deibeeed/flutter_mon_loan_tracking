// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoanSchedule _$LoanScheduleFromJson(Map<String, dynamic> json) => LoanSchedule(
      date: json['date'] as num,
      outstandingBalance: json['outstandingBalance'] as num,
      monthlyAmortization: json['monthlyAmortization'] as num,
      principalPayment: json['principalPayment'] as num,
      interestPayment: json['interestPayment'] as num,
      incidentalFee: json['incidentalFee'] as num,
      loanId: json['loanId'] as String,
      id: json['id'] as String,
      createdAt: json['createdAt'] as num,
    )..paidOn = json['paidOn'] as num?;

Map<String, dynamic> _$LoanScheduleToJson(LoanSchedule instance) =>
    <String, dynamic>{
      'date': instance.date,
      'outstandingBalance': instance.outstandingBalance,
      'monthlyAmortization': instance.monthlyAmortization,
      'principalPayment': instance.principalPayment,
      'interestPayment': instance.interestPayment,
      'incidentalFee': instance.incidentalFee,
      'paidOn': instance.paidOn,
      'loanId': instance.loanId,
      'id': instance.id,
      'createdAt': instance.createdAt,
    };
