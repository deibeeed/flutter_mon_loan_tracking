import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/app/app.dart';
import 'package:flutter_mon_loan_tracking/bootstrap.dart';

import 'package:flutter_mon_loan_tracking/firebase_options_stg.dart';
import 'package:flutter_mon_loan_tracking/services/environments.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Constants.currentEnvironment = Environments.staging;
  bootstrap(() => App());
}
