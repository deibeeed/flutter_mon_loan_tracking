import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MenuItemModel extends Equatable {
  const MenuItemModel({
    required this.name,
    required this.goPath,
    this.isSeparator = false,
    this.isDynamic = false,
    this.icon,
    this.shortName,
  });

  final String name;
  final String goPath;
  final bool isSeparator;
  final bool isDynamic;
  final Widget? icon;
  final String? shortName;

  String get computedShortName => shortName ?? name;

  @override
  List<Object?> get props =>
      [
        name,
        goPath,
        isSeparator,
        isDynamic,
        icon,
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

class DynamicMenuItem extends MenuItemModel {
  const DynamicMenuItem({ required String name}):
    super(
      name: name,
      goPath: '/$name',
      isSeparator: false,
      isDynamic: true,
    );
}
