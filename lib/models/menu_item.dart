import 'package:equatable/equatable.dart';

class MenuItemModel extends Equatable {
  const MenuItemModel({
    required this.name,
    required this.goPath,
    this.isSeparator = false,
  });

  final String name;
  final String goPath;
  final bool isSeparator;

  @override
  List<Object?> get props => [
        name,
        goPath,
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
