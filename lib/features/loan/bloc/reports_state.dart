part of 'reports_bloc.dart';

sealed class ReportsState {
  const ReportsState();
}

final class ReportsInitial extends ReportsState {
  @override
  List<Object> get props => [];
}

final class ShowReportState extends ReportsState {
  final double totalLoanAmount;
  final double totalExpectedCollections;
  // expressed in percentage
  final double totalExpectedProfit;
  final double totalExpectedProfitPercent;
  // expressed in percentage
  final double totalActualCollectionsProfit;
  final double totalActualCollectionsProfitPercent;
  final int overdueCount;

  ShowReportState({
    required this.totalLoanAmount,
    required this.totalExpectedCollections,
    required this.totalExpectedProfit,
    required this.totalActualCollectionsProfit,
    required this.overdueCount,
    required this.totalActualCollectionsProfitPercent,
    required this.totalExpectedProfitPercent,
  });

  @override
  List<Object?> get props => [];
}
