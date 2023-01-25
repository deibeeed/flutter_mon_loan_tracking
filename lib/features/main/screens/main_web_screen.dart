import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/widgets/main_web_screen_menu.dart';
import 'package:go_router/go_router.dart';

class MainWebScreen extends StatelessWidget {
  const MainWebScreen({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final computedWidth = width * 0.88;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(220),
        child: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.48),
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Container(
              width: computedWidth,
              margin: const EdgeInsets.only(bottom: 48),
              child: BlocBuilder<MenuSelectionCubit, MenuSelectionState>(
                builder: (context, state) {
                  var menuItemName = Constants.menuItems[0].name;
                  if (state is MenuPageSelected) {
                    menuItemName = Constants.menuItems[state.page].name;
                  }

                  return Text(
                    menuItemName,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.apply(color: Colors.white),
                  );
                },
              ),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Constants.defaultRadius,
              bottomRight: Constants.defaultRadius,
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 68),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: MainWebScreenMenu(),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(58),
                child: content,
              ),
            )
          ],
        ),
      ),
    );
  }
}
