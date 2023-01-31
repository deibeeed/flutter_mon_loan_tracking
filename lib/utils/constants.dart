import 'dart:ui';

import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/services/environments.dart';

class Constants {
  static Environments currentEnvironment = Environments.dev;
  static const String NO_ID = 'no_id_available';
  static const defaultRadius = Radius.circular(120);
  static const menuItems = [
    MenuItemModel(name: 'Loan Dashboard', goPath: '/loan-dashboard'),
    MenuItemModel(name: 'Lot Dashboard', goPath: '/lot-dashboard'),
    MenuItemModel(name: 'Users', goPath: '/users'),
    MenuItemModel(name: 'Settings', goPath: '/settings'),
    MenuItemSeparator(),
    MenuItemModel(name: 'Loan Calculator', goPath: '/loan-calculator'),
  ];
  static const loan_dashboard_table_columns = [
    'Name',
    'Block No.  / Lot No.',
    'Payment Status',
    'Amount',
    'Agent',
  ];
  static const loan_dashboard_general_filters = [
    'All',
    'Paid',
    'Unpaid',
    'Overdue'
  ];

  static const lot_dashbaord_general_filters = [
    'All',
    'Available',
    'Unavailable',
  ];

  static const user_list_table_colums = [
    'Name',
    'Type',
    'Contact Number',
    'Date Added'
  ];

  static const loan_schedule_table_columns = [
    'Date',
    'Outstanding balance',
    'Monthly amortization',
    'Principal payment',
    'Interest payment',
    'Incidental fees'
  ];
}