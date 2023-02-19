import 'package:equatable/equatable.dart';

class MenuItemModel extends Equatable {
  const MenuItemModel({
    required this.name,
    required this.goPath,
    this.isSeparator = false,
    this.isDynamic = false,
  });

  final String name;
  final String goPath;
  final bool isSeparator;
  final bool isDynamic;

  @override
  List<Object?> get props =>
      [
        name,
        goPath,
        isSeparator,
        isDynamic,
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
