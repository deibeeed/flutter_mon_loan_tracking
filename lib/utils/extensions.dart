import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

extension CurrencyParsing on num {
  String toCurrency({ bool isDeduction = false}) {
    var formatted = Constants.defaultCurrencyFormat
        .format(num.parse(toStringAsFixed(2)));
    final diff = (formatted.length - 1) - formatted.indexOf('.');

    if (formatted.startsWith('-')) {
      formatted = formatted.substring(1);
    }

    if (isDeduction) {
      return formatted.replaceFirst(' ', ' -');
    }

    if (diff == 1) {
      return '${formatted}0';
    }

    return formatted;
  }
}
