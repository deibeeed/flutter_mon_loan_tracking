import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MenuItemModel extends Equatable {
  const MenuItemModel({
    required this.name,
    required this.goPath,
    this.isSeparator = false,
    this.isDynamic = false,
    this.iconSvgAssetPath,
    this.shortName,
  });

  final String name;
  final String goPath;
  final bool isSeparator;
  final bool isDynamic;
  final String? iconSvgAssetPath;
  final String? shortName;

  String get computedShortName => shortName ?? name;

  @override
  List<Object?> get props =>
      [
        name,
        goPath,
        isSeparator,
        isDynamic,
        iconSvgAssetPath,
        shortName
      ];
}

class MenuItemSeparator extends MenuItemModel {
  const MenuItemSeparator()
      : super(
    name: 'separator',
    goPath: '/separator',
    isSeparator: true,
  );
}
