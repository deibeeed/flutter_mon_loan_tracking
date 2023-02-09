import 'package:json_annotation/json_annotation.dart';

part 'discount.g.dart';

@JsonSerializable()
class Discount {
  final num discount;
  final String description;

  const Discount({required this.discount, required this.description});

  factory Discount.fromJson(Map<String, dynamic> json) =>
      _$DiscountFromJson(json);

  toJson() => _$DiscountToJson(this);
}
