import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class MainWebScreenMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var textStyle = Theme.of(context).textTheme.titleLarge;
    var dottedButtonRadius = Constants.defaultRadius;
    double? dottedButtonHeight = 86.0;
    var dottedButtonMargin = const EdgeInsets.only(
      right: 64,
      top: 48,
      bottom: 48,
      left: 32,
    );

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      // cardRadius = 48;
      // cardPadding = 32;
      // buttonHeight = 56;
      // buttonPadding = 8;
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      textStyle = Theme.of(context).textTheme.titleSmall;
      dottedButtonRadius = const Radius.circular(32);
      dottedButtonHeight = null;
      dottedButtonMargin = const EdgeInsets.only(
        right: 32,
        top: 48,
        bottom: 32,
        left: 32,
      );
    }

    final menuSelection = BlocProvider.of<MenuSelectionCubit>(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topRight: loginContainerRadius,
          bottomRight: loginContainerRadius,
        ),
      ),
      child: BlocBuilder<MenuSelectionCubit, MenuSelectionState>(
        builder: (context, state) {
          var page = 0;
          var addButtonTitle = 'Add Loan';
          var addButtonPath = '/add-loan';

          if (state is MenuPageSelected) {
            page = state.page;
          }

          switch (page) {
            case 0:
              addButtonTitle = 'Add Loan';
              addButtonPath = '/add-loan';
              break;
            case 1:
              addButtonTitle = 'Add Lot';
              addButtonPath = '/add-lot';
              break;
            case 2:
              addButtonTitle = 'Add User';
              addButtonPath = '/add-user';
              break;
          }

          return ListView(
            children: [
              Container(
                margin: dottedButtonMargin,
                height: dottedButtonHeight,
                child: Visibility(
                  visible: page <= 2,
                  child: InkWell(
                    onTap: () {
                      GoRouter.of(context).push(addButtonPath);
                    },
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      color: Colors.white,
                      dashPattern: const [6, 4],
                      strokeWidth: 2,
                      padding: const EdgeInsets.all(16),
                      radius: dottedButtonRadius,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              addButtonTitle,
                              style: textStyle?.apply(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ...Constants.menuItems
                  .where((menu) => !menu.isDynamic)
              .mapIndexed((i, menu) => _buildMenuItem(
                context: context,
                item: menu,
                selected: page == i,
                onTap: () {
                  menuSelection.select(page: i);
                  GoRouter.of(context).go(menu.goPath);
                },
              ),).toList()

            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required MenuItemModel item,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;

    if (item.isSeparator) {
      var paddingRight = 64.0;
      if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
        paddingRight = 32;
      }
      return Padding(
        padding:
            EdgeInsets.only(left: 40, right: paddingRight, top: 16, bottom: 16),
        child: const Divider(
          color: Colors.white,
          thickness: 1.5,
          height: 4,
        ),
      );
    }

    var textStyle = Theme.of(context).textTheme.titleLarge;
    var paddingRight = 100.0;
    var minVerticalPadding = 32.0;
    Widget titleWidget = Padding(
      padding: EdgeInsets.only(right: paddingRight),
      child: Text(
        item.name,
        style: textStyle?.apply(color: Colors.white),
      ),
    );

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      textStyle = Theme.of(context).textTheme.titleSmall;
      paddingRight = 16;
      minVerticalPadding = 4;
      titleWidget = Padding(
        padding: EdgeInsets.only(right: paddingRight),
        child: Text(
          item.name,
          style: textStyle?.apply(color: Colors.white),
        ),
      );
    } else {
      titleWidget = Center(
        child: titleWidget,
      );
    }

    return ListTile(
      minVerticalPadding: minVerticalPadding,
      leading: Container(
        width: 7,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      title: titleWidget,
      onTap: onTap,
    );
  }
}
