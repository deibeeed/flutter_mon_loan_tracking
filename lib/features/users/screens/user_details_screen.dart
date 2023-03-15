import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/civil_status_types.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_mon_loan_tracking/widgets/pdf_generator.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'user_details_screen_small.dart';

part 'user_details_screen_large.dart';

part 'user_details_screen_utils.dart';

class UserDetailsScreen extends StatefulWidget {
  UserDetailsScreen({super.key});

  // NOTE: userId is required
  String? userId;
  bool isProfile = false;

  @override
  State<StatefulWidget> createState() {
    return _UserDetailsScreenState();
  }
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final civilStatusController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final birthDateController = TextEditingController();
  final _pagingController =
      PagingController<int, LoanSchedule>(firstPageKey: 0);

  @override
  void deactivate() {
    Constants.appBarTitle = null;

    context.read<UserBloc>().reset();
    context.read<LoanBloc>().reset();
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().getAllUsers();
    context.read<LoanBloc>()
      ..getAllLots()
      ..getAllLoans(clearList: true, clientId: widget.userId);

    // _pagingController.addPageRequestListener((pageKey) {
    //   context.read<LoanBloc>().getAllLoans();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    final loanBloc = BlocProvider.of<LoanBloc>(context);

    final userBloc = BlocProvider.of<UserBloc>(context);

    if (widget.userId != null) {
      userBloc.selectUser(userId: widget.userId!);
    }

    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
    }

    final width = screenSize.width;
    final computedWidth = width * 0.88;
    var appBarHeight = screenSize.height * 0.16;
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
    final shouldShowAppBar = widget.isMobile() /*|| widget.isProfile*/;
    printd('size: ${MediaQuery.of(context).size}');

    return MultiBlocListener(
      listeners: [
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserSuccessState) {
              if (userBloc.selectedUser != null) {
                final user = userBloc.selectedUser!;
                lastNameController.text = user.lastName;
                firstNameController.text = user.firstName;
                mobileNumberController.text = user.mobileNumber;
                emailController.text = user.email;
                civilStatusController.text = user.civilStatus.value;
                birthDateController.text = user.birthDate;
              }
            } else if (state is UserErrorState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is UserLoadingState) {
              if (state.isLoading) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return const AlertDialog(
                        content: SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    });
              } else {
                try {
                  if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } catch (err) {
                  printd(err);
                }
              }
            }
          },
        ),
        BlocListener<LoanBloc, LoanState>(
          listener: (context, state) {
            if (state is LoanDisplaySummaryState) {
              _pagingController.value = PagingState(
                itemList: loanBloc.clientLoanSchedules,
              );
            }
          },
        )
      ],
      child: Scaffold(
        appBar: !shouldShowAppBar
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight),
                child: AppBar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.48),
                  leading: !shouldShowAppBar
                      ? Container()
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => GoRouter.of(context).pop(),
                        ),
                  bottom: PreferredSize(
                    preferredSize: Size.zero,
                    child: Container(
                      width: computedWidth,
                      margin: EdgeInsets.only(bottom: appBarBottomPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userBloc.selectedUser?.completeName ?? 'User',
                            style: titleTextStyle?.apply(color: Colors.white),
                          ),
                          SizedBox(
                            width: avatarSize,
                            height: avatarSize,
                            child: InkWell(
                              onTap: () {
                                final user = userBloc.getLoggedInUser();
                                if (user != null) {
                                  GoRouter.of(context)
                                      .push('/users/${user.id}');
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    userBloc.getLoggedInUser()?.initials ??
                                        'No',
                                    style: avatarTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
        body: shortestSide <= Constants.smallScreenShortestSideBreakPoint
            ? buildSmallScreenBody(
                context: context,
                userId: widget.userId,
                isProfile: widget.isProfile,
                lastNameController: lastNameController,
                firstNameController: firstNameController,
                mobileNumberController: mobileNumberController,
                emailController: emailController,
                civilStatusController: civilStatusController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                birthDateController: birthDateController,
                pagingController: _pagingController,
              )
            : buildLargeScreenBody(
                context: context,
                userId: widget.userId,
                isProfile: widget.isProfile,
                lastNameController: lastNameController,
                firstNameController: firstNameController,
                mobileNumberController: mobileNumberController,
                emailController: emailController,
                civilStatusController: civilStatusController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                birthDateController: birthDateController,
                pagingController: _pagingController,
              ),
      ),
    );
  }
}
