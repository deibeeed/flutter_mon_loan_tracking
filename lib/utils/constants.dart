import 'dart:ui';

import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/services/environments.dart';
import 'package:intl/intl.dart';

class Constants {
  static const currency = '₱';
  static Environments currentEnvironment = Environments.dev;
  static const String NO_ID = 'no_id_available';
  static const num NO_DATE = -1;
  static const defaultRadius = Radius.circular(120);
  static var defaultDateFormat = DateFormat('yyyy-MMM-dd');
  static var defaultCurrencyFormat =
      NumberFormat('${Constants.currency} ###,###,###,###,###,##0.00');
  static const menuItems = [
    MenuItemModel(name: 'Loan Dashboard', goPath: '/loan-dashboard'),
    MenuItemModel(name: 'Lot Dashboard', goPath: '/lot-dashboard'),
    MenuItemModel(name: 'Users', goPath: '/users'),
    MenuItemModel(name: 'Settings', goPath: '/settings'),
    MenuItemSeparator(),
    MenuItemModel(name: 'Loan Calculator', goPath: '/loan-calculator'),
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
