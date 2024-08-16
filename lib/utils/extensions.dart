import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';

extension FormattingExtension on num {
  String toCurrency({
    bool isDeduction = false,
    bool optionalDecimal = false,
    bool removeNegative = true,
  }) {
    var formatted =
        Constants.defaultCurrencyFormat.format(num.parse(toStringAsFixed(2)));

    if (optionalDecimal) {
      formatted = Constants.defaultCurrencyFormatOptionalDecimal.format(this);
    }

    // final diff = (formatted.length - 1) - formatted.indexOf('.');

    if (removeNegative && formatted.startsWith('-')) {
      formatted = formatted.substring(1);
    }

    if (isDeduction) {
      return formatted.replaceFirst(' ', ' -');
    }

    // if (diff == 1) {
    //   return '${formatted}0';
    // }

    return formatted;
  }

  String toPercent() {
    return '${toStringAsFixed(2)}%';
  }

  String toDefaultDate() {
    return Constants.defaultDateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(toInt()),
    );
  }
}

extension DateTimeExtension on DateTime {
  String toDefaultDate() {
    return Constants.defaultDateFormat.format(
      this,
    );
  }
}

extension MobileChecking on Widget {
  bool isMobile() {
    // final mobilePlatforms = [
    //   TargetPlatform.android,
    //   TargetPlatform.iOS,
    // ];
    // return mobilePlatforms.contains(defaultTargetPlatform);
    return !Constants.isWebOrLargeScreen;
  }
}
