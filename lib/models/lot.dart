import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lot.g.dart';

@JsonSerializable()
class Lot extends Equatable {
  final String lotCategory;
  final num totalContractPrice;
  final String blockNo;
  final String lotNo;
  final String description;
  final String id;
  String? clientId;
  final num createdAt;
  num updatedAt;
  num area;

  Lot({
    required this.lotCategory,
    required this.totalContractPrice,
    required this.blockNo,
    required this.lotNo,
    required this.area,
    required this.description,
    this.id = Constants.NO_ID,
    this.clientId,
    this.updatedAt = Constants.NO_DATE,
    required this.createdAt,
  });

  factory Lot.fromJson(Map<String, dynamic> json) => _$LotFromJson(json);

  factory Lot.updateId({required String id, required Lot lot}) => Lot(
        lotCategory: lot.lotCategory,
        totalContractPrice: lot.totalContractPrice,
        blockNo: lot.blockNo,
        lotNo: lot.lotNo,
        description: lot.description,
        id: id,
        area: lot.area,
        clientId: lot.clientId,
        createdAt: lot.createdAt,
      );

  factory Lot.create({
    required String lotCategory,
    required num totalContractPrice,
    required String blockNo,
    required String lotNo,
    required String description,
    required num area,
  }) =>
      Lot(
        lotCategory: lotCategory,
        totalContractPrice: totalContractPrice,
        blockNo: blockNo,
        lotNo: lotNo,
        area: area,
        description: description,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toJson() => _$LotToJson(this);

  @override
  List<Object?> get props => [
        lotCategory,
        totalContractPrice,
        blockNo,
        lotNo,
        description,
        id,
        clientId,
        area,
        createdAt,
        updatedAt
      ];
}
