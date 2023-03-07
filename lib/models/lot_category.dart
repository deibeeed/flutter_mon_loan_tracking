import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lot_category.g.dart';

@JsonSerializable()
class LotCategory extends Equatable {
  final String key;
  final String name;
  final num ratePerSquareMeter;

  const LotCategory({required this.name, required this.ratePerSquareMeter});

  @override
  List<Object?> get props => [
        name,
        ratePerSquareMeter,
      ];

  Map<String, dynamic> toJson() => _$LotCategoryToJson(this);

  factory LotCategory.fromJson(Map<String, dynamic> json) =>
      _$LotCategoryFromJson(json);
}
