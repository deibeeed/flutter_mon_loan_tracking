import 'dart:ui';

import 'package:flutter_mon_loan_tracking/models/menu_item.dart';

class Constants {
  static const defaultRadius = Radius.circular(120);
  static const menuItems = [
    MenuItemModel(name: 'Loan Dashboard', goPath: '/loan-dashboard'),
    MenuItemModel(name: 'Lot Dashboard', goPath: '/lot-dashboard'),
    MenuItemModel(name: 'Users', goPath: '/users'),
    MenuItemModel(name: 'Settings', goPath: '/settings'),
    MenuItemSeparator(),
    MenuItemModel(name: 'Loan Calculator', goPath: '/loan-calculator'),
  ];
}