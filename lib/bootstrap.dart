import 'dart:async';
import 'dart:developer';
import 'dart:math' as Math;

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = AppBlocObserver();

  final plugin = DeviceInfoPlugin();
  final deviceInfo = await plugin.deviceInfo;
  printd('info: ${deviceInfo.data}.');

  if (deviceInfo is AndroidDeviceInfo) {
    final smallestSide = Math.min(
      deviceInfo.displayMetrics.widthPx,
      deviceInfo.displayMetrics.heightPx,
    );
    final devicePixelRatio = deviceInfo.displayMetrics.xDpi / 160;
    final smallestSideSize = smallestSide / devicePixelRatio;
    printd('smallestSizeSize: $smallestSideSize');

    Constants.isWebOrLargeScreen =
        smallestSideSize >= Constants.largeScreenShortestSideStartBreakPoint;
  } else if (deviceInfo is IosDeviceInfo) {
    Constants.isWebOrLargeScreen = deviceInfo.model != 'iPhone';
  }

  await runZonedGuarded(
    () async => runApp(await builder()),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
