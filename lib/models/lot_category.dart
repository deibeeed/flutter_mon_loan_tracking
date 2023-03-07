import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lot_category.g.dart';

@JsonSerializable()
class LotCategory extends Equatable {
  final String name;
  final num perSquareMeterRate;

  const LotCategory({required this.name, required this.perSquareMeterRate});

  @override
  List<Object?> get props => [
        name,
        perSquareMeterRate,
      ];

  Map<String, dynamic> toJson() => _$LotCategoryToJson(this);

  factory LotCategory.fromJson(Map<String, dynamic> json) =>
      _$LotCategoryFromJson(json);
}
