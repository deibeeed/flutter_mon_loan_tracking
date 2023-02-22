import 'dart:ui';

import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/services/environments.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class Constants {
  static const maxAppBarHeight = 220.0;
  static const largeScreenShortestSideBreakPoint = 800;
  static const smallScreenShortestSideBreakPoint = 420;
  static const currency = '₱';
  static Environments currentEnvironment = Environments.dev;
  static const String NO_ID = 'no_id_available';
  static const num NO_DATE = -1;
  static const defaultRadius = Radius.circular(120);
  static var defaultDateFormat = DateFormat('yyyy-MMM-dd');
  static var defaultCurrencyFormat =
      NumberFormat('${Constants.currency} ###,###,###,###,###,##0.00');
  static var menuItems = [
    const MenuItemModel(
      name: 'Loan Dashboard',
      goPath: '/loan-dashboard',
      shortName: 'Loans',
      iconSvgAssetPath: 'assets/icons/mortgage-loan.svg',
    ),
    const MenuItemModel(
      name: 'Lot Dashboard',
      goPath: '/lot-dashboard',
      shortName: 'Lots',
      iconSvgAssetPath: 'assets/icons/land.svg',
    ),
    const MenuItemModel(
      name: 'Users',
      goPath: '/users',
      iconSvgAssetPath: 'assets/icons/user.svg',
    ),
    const MenuItemModel(
      name: 'Settings',
      goPath: '/settings',
      iconSvgAssetPath: 'assets/icons/settings.svg',
    ),
    const MenuItemSeparator(),
    const MenuItemModel(
      name: 'Loan Calculator',
      goPath: '/loan-calculator',
      shortName: 'Calculator',
      iconSvgAssetPath: 'assets/icons/finance.svg',
    ),
  ];
  static const loan_dashboard_table_columns = [
    'Date',
    'Name',
    'Block No.  / Lot No.',
    'Payment Status',
    'Amount',
    'Agent',
  ];
  static const loan_dashboard_general_filters = [
    'All',
    'Paid',
    // 'Unpaid',
    'Overdue'
  ];

  static const lot_dashbaord_general_filters = [
    'All',
    'Available',
    'Unavailable',
  ];

  static const user_list_table_colums = [
    'Name',
    'Civil status',
    'Type',
    'Contact number',
    'Birth date'
  ];

  static const loan_schedule_table_columns = [
    'Date',
    'Outstanding balance',
    'Monthly amortization',
    'Principal payment',
    'Interest payment',
    'Incidental fees'
  ];

  static const user_loan_schedule_table_columns = [
    'Date',
    'Outstanding balance',
    'Monthly amortization',
    'Principal payment',
    'Interest payment',
    'Incidental fees',
    'Status'
  ];
}
