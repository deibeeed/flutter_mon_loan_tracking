import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/app/app.dart';
import 'package:flutter_mon_loan_tracking/bootstrap.dart';

import 'package:flutter_mon_loan_tracking/firebase_options.dart';
import 'package:flutter_mon_loan_tracking/services/environments.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Constants.currentEnvironment = Environments.production;
  bootstrap(() => App());
}
