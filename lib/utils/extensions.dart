import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';

extension FormattingExtension on num {
  String toCurrency({bool isDeduction = false}) {
    var formatted =
        Constants.defaultCurrencyFormat.format(num.parse(toStringAsFixed(2)));
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

  String toDefaultDate() {
    return Constants.defaultDateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(toInt()),
    );
  }

  String withUnit() {
    return '$this sqm';
  }
}

extension MobileChecking on StatelessWidget {
  bool isMobile() {
    final mobilePlatforms = [
      TargetPlatform.android,
      TargetPlatform.iOS,
    ];
    return mobilePlatforms.contains(defaultTargetPlatform);
  }
}

extension MobileChecking2 on Widget {
  bool isMobile() {
    final mobilePlatforms = [
      TargetPlatform.android,
      TargetPlatform.iOS,
    ];
    return mobilePlatforms.contains(defaultTargetPlatform);
  }
}