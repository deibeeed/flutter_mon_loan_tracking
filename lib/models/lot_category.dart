import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lot_category.g.dart';

@JsonSerializable()
class LotCategory extends Equatable {
  final String name;
  num ratePerSquareMeter;

  LotCategory({required this.name, required this.ratePerSquareMeter});

  @override
  List<Object?> get props => [
        name,
        ratePerSquareMeter,
      ];

  String get key => name.trim().replaceAll(' ', '_');

  Map<String, dynamic> toJson() => _$LotCategoryToJson(this);

  factory LotCategory.fromJson(Map<String, dynamic> json) =>
      _$LotCategoryFromJson(json);
}
