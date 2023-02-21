import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:go_router/go_router.dart';

class MainSmallScreen extends StatelessWidget {
  const MainSmallScreen({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final computedWidth = width * 0.88;
    final shortestSide = screenSize.shortestSide;
    var appBarHeight = screenSize.height * 0.16;
    var cardRadius = 100.0;
    var cardPadding = 56.0;
    var buttonHeight = 72.0;
    var buttonPadding = 24.0;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var titleTextStyle = Theme.of(context).textTheme.displaySmall;
    var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
    var avatarSize = 56.0;
    var contentPadding = const EdgeInsets.all(58);
    var appBarBottomPadding = 48.0;

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      cardRadius = 48;
      cardPadding = 32;
      buttonHeight = 56;
      buttonPadding = 8;
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      titleTextStyle = Theme.of(context).textTheme.headlineMedium;
      avatarTextStyle = Theme.of(context).textTheme.titleSmall;
      avatarSize = 48;
      contentPadding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 16,
      );
      appBarBottomPadding = 24;
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.48),
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Container(
              width: computedWidth,
              margin: EdgeInsets.only(bottom: appBarBottomPadding),
              child: BlocBuilder<MenuSelectionCubit, MenuSelectionState>(
                builder: (context, state) {
                  var menuItemName = Constants.menuItems[0].name;
                  if (state is MenuPageSelected) {
                    menuItemName = Constants.menuItems[state.page].name;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        menuItemName,
                        style: titleTextStyle?.apply(color: Colors.white),
                      ),
                      SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: InkWell(
                          onTap: () {
                            final user = userBloc.getLoggedInUser();
                            if (user != null) {
                              Constants.menuItems.add(
                                DynamicMenuItem(
                                  name: user.completeName,
                                ),
                              );
                              context.read<MenuSelectionCubit>().select(
                                    page: Constants.menuItems.length - 1,
                                  );
                              userBloc.selectUser(userId: user.id);
                              GoRouter.of(context).go('/users/${user.id}');
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                userBloc.getLoggedInUser()?.initials ?? 'No',
                                style: avatarTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: loginContainerRadius,
              bottomRight: loginContainerRadius,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: Constants.menuItems
              .where((item) => !item.isSeparator && !item.isDynamic)
              .map(
                (item) => InkWell(
                  onTap: () => GoRouter.of(context).go(item.goPath),
                  child: SizedBox(
                    width: 72,
                    height: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        item.icon ??
                            Icon(
                              Icons.add,
                            ),
                        Text(item.computedShortName)
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}
