import 'package:flutter_mon_loan_tracking/utils/constants.dart';

extension CurrencyParsing on num {
  String toCurrency() {
    return '${Constants.currency} ${toStringAsFixed(2)}';
  }
}
