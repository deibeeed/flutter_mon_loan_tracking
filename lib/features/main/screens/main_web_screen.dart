import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/widgets/main_web_screen_menu.dart';
import 'package:go_router/go_router.dart';

class MainLargeScreen extends StatelessWidget {
  const MainLargeScreen({super.key, required this.content});

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
                        Constants.appBarTitle ?? menuItemName,
                        style: titleTextStyle?.apply(color: Colors.white),
                      ),
                      SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: InkWell(
                          onTap: () {
                            final user = userBloc.getLoggedInUser();
                            if (user != null) {
                              Constants.appBarTitle = user.completeName;
                              context.read<MenuSelectionCubit>().select(
                                page: 2,
                              );
                              GoRouter.of(context).go('/profile/${user.id}');
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
      body: Container(
        margin: EdgeInsets.only(top: loginContainerMarginTop),
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
                padding: contentPadding,
                child: content,
              ),
            )
          ],
        ),
      ),
    );
  }
}
