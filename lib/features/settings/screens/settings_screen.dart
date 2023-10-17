import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/setting_field.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/settings_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/debounce.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'settings_screen_small.dart';

part 'settings_screen_large.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key}) : super();

  final loanInterestRateController = TextEditingController();
  final incidentalFeesRateController = TextEditingController();
  final serviceFeeController = TextEditingController();
  final lotCategoryNameController = TextEditingController();
  final lotCategoryPricePerSqmController = TextEditingController();
  final downPaymentRateController = TextEditingController();
  final vatRateController = TextEditingController();
  final vattableTCPController = TextEditingController();
  bool allowTextControllerUpdate = true;

  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    settingsBloc.getSettings();

    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
    }

    return Scaffold(
      body: shortestSide <= Constants.smallScreenShortestSideBreakPoint
          ? buildSmallScreenBody(
          context: context,
          loanInterestRateController: loanInterestRateController,
          incidentalFeesRateController: incidentalFeesRateController,
          serviceFeeController: serviceFeeController,
          lotCategoryNameController: lotCategoryNameController,
          lotCategoryPricePerSqmController: lotCategoryPricePerSqmController,
          downPaymentRateController: downPaymentRateController,
          vatRateController: vatRateController,
          vattableTCPController: vattableTCPController,
          allowTextControllerUpdate: allowTextControllerUpdate,
      )
          : buildLargeScreenBody(
        context: context,
        loanInterestRateController: loanInterestRateController,
        incidentalFeesRateController: incidentalFeesRateController,
        serviceFeeController: serviceFeeController,
        lotCategoryNameController: lotCategoryNameController,
        lotCategoryPricePerSqmController: lotCategoryPricePerSqmController,
        downPaymentRateController: downPaymentRateController,
        vatRateController: vatRateController,
        vattableTCPController: vattableTCPController,
        allowTextControllerUpdate: allowTextControllerUpdate,
      ),
    );
  }
}
