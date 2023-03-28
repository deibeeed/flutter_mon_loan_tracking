import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/app/app.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainSmallScreen extends StatelessWidget {
  const MainSmallScreen({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    final menuSelection = BlocProvider.of<MenuSelectionCubit>(context);
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
    var bottomMenuSelectedColor =
        Theme.of(context).colorScheme.tertiary.withOpacity(0.8);
    var bottomMenuUnselectedColor =
        Theme.of(context).colorScheme.primaryContainer;
    const bottomBarSelectedBorderRadius = BorderRadius.all(Radius.circular(24));

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
                    menuItemName = Constants.getMenuByUserType(
                      type: userBloc.getLoggedInUser()?.type,
                    )
                        .where((item) => !item.isSeparator && !item.isDynamic)
                        .toList()[state.page]
                        .name;
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
                              Constants.appBarTitle = user.completeName;
                              context.read<MenuSelectionCubit>().select(
                                    page: 2,
                                  );
                              GoRouter.of(context).push('/profile/${user.id}');
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
      floatingActionButton: BlocBuilder<MenuSelectionCubit, MenuSelectionState>(
        builder: (context, state) {
          var pageSelected = 0;
          if (state is MenuPageSelected) {
            pageSelected = state.page;
            if (state.page > 2) {
              return Container();
            }
          }

          return Visibility(
            visible: pageSelected <= 2 &&
                [UserType.admin, UserType.subAdmin]
                    .contains(userBloc.getLoggedInUser()?.type),
            child: FloatingActionButton.small(
              onPressed: () {
                switch (pageSelected) {
                  case 0:
                    GoRouter.of(context).push('/add-loan');
                    break;
                  case 1:
                    GoRouter.of(context).push('/add-lot');
                    break;
                  case 2:
                    GoRouter.of(context).push('/add-user');
                    break;
                }
              },
              child: Icon(Icons.add),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: BottomAppBar(
          elevation: 24,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: const AutomaticNotchedShape(
            // RoundedRectangleBorder(
            //     borderRadius: BorderRadius.only(
            //       topLeft: Radius.circular(16),
            //       topRight: Radius.circular(16),
            //     )),
            RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(56))),
            StadiumBorder(),
          ),
          child: BlocBuilder<MenuSelectionCubit, MenuSelectionState>(
            builder: (context, state) {
              var page = 0;

              if (state is MenuPageSelected) {
                page = state.page;
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: Constants.getMenuByUserType(
                  type: userBloc.getLoggedInUser()?.type,
                )
                    .where((item) => !item.isSeparator && !item.isDynamic)
                    .mapIndexed(
                      (i, item) => InkWell(
                        borderRadius: bottomBarSelectedBorderRadius,
                        onTap: () {
                          menuSelection.select(page: i);
                          GoRouter.of(context).go(item.goPath);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: bottomBarSelectedBorderRadius,
                            color: page == i ? bottomMenuSelectedColor : null,
                          ),
                          width: 68,
                          height: 68,
                          child: Column(
                            children: [
                              Expanded(
                                  child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (item.iconSvgAssetPath != null)
                                    SvgPicture.asset(
                                      item.iconSvgAssetPath!,
                                      width: 20,
                                      height: 20,
                                      color: page == i
                                          ? bottomMenuUnselectedColor
                                          : bottomMenuSelectedColor,
                                    )
                                  else
                                    SvgPicture.asset(
                                      'assets/icons/mortgage-loan.svg',
                                      width: 24,
                                      height: 24,
                                      color: page == i
                                          ? bottomMenuUnselectedColor
                                          : bottomMenuSelectedColor,
                                    ),
                                  Text(
                                    item.computedShortName,
                                    style: TextStyle(
                                      color: page == i
                                          ? bottomMenuUnselectedColor
                                          : bottomMenuSelectedColor,
                                    ),
                                  )
                                ],
                              ))
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}
