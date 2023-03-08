import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/lot_category.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lot.g.dart';

@JsonSerializable()
class Lot extends Equatable {
  final String lotCategoryKey;
  final String blockNo;
  final String lotNo;
  final String description;
  final String id;
  final num createdAt;
  num updatedAt;
  final num area;

  // user id of the customer that bought the lot
  String? reservedTo;

  Lot({
    required this.lotCategoryKey,
    required this.blockNo,
    required this.lotNo,
    required this.area,
    required this.description,
    this.id = Constants.NO_ID,
    this.updatedAt = Constants.NO_DATE,
    required this.createdAt,
    this.reservedTo,
  });

  factory Lot.fromJson(Map<String, dynamic> json) => _$LotFromJson(json);

  factory Lot.updateId({required String id, required Lot lot}) => Lot(
        lotCategoryKey: lot.lotCategoryKey,
        blockNo: lot.blockNo,
        lotNo: lot.lotNo,
        description: lot.description,
        id: id,
        area: lot.area,
        createdAt: lot.createdAt,
        updatedAt: lot.updatedAt,
        reservedTo: lot.reservedTo,
      );

  factory Lot.create({
    required String lotCategoryKey,
    required String blockNo,
    required String lotNo,
    required String description,
    required num area,
    String? reservedTo,
  }) =>
      Lot(
        lotCategoryKey: lotCategoryKey,
        blockNo: blockNo,
        lotNo: lotNo,
        area: area,
        description: description,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        reservedTo: reservedTo,
      );

  Map<String, dynamic> toJson() => _$LotToJson(this);

  String get completeBlockLotNo => 'Blk $blockNo Lot $lotNo';

  @override
  List<Object?> get props => [
        lotCategoryKey,
        blockNo,
        lotNo,
        description,
        id,
        area,
        createdAt,
        updatedAt,
        reservedTo,
      ];
}
