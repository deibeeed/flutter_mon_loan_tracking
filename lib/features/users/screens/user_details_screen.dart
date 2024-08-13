import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mon_loan_tracking/features/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_mon_loan_tracking/widgets/pdf_generator.dart';
import 'package:flutter_mon_loan_tracking/widgets/user_form_widget_large.dart';
import 'package:flutter_mon_loan_tracking/widgets/user_form_widget_small.dart';
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
  final _pagingController =
      PagingController<int, LoanSchedule>(firstPageKey: 0);
  final _formKey =
      GlobalKey<FormBuilderState>(debugLabel: 'user_details_screen');
  bool _showLoanLoadingDialog = false;

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
    context.read<UserBloc>().initializeAddUser(withId: widget.userId);
    context.read<LoanBloc>()
      ..getAllLoans(clearList: true, clientId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    final loanBloc = BlocProvider.of<LoanBloc>(context);

    final userBloc = BlocProvider.of<UserBloc>(context);

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
                _showLoanLoadingDialog = true;
              }
            } else if (state is UpdateUiState) {
              final user = userBloc.tempUser;
              final spouse = userBloc.tempUserSpouse;
              final address = userBloc.tempUserAddress;
              final edUser = userBloc.tempUserEmploymentDetails;
              final edUserSpouse = userBloc.tempUserSpouseEmploymentDetails;
              final beneficiaries = userBloc.tempUserBeneficiaries;

              final values = <String, dynamic>{
                'userType': user?.type,
                'nationality': user?.nationality,
                'lastName': user?.lastName,
                'firstName': user?.firstName,
                'middleName': user?.middleName,
                'civilStatus': user?.civilStatus,
                'gender': user?.gender,
                'birthDate': user?.birthDate,
                'birthPlace': user?.birthPlace,
                'weight': user?.weight,
                'height': user?.height,
                'tinNo': user?.tinNo,
                'sssNo': user?.sssNo,
                'philHealthNo': user?.philHealthNo,
                'mobileNo': user?.mobileNumber,
                'telNo': user?.telNo,
                'email': user?.email,
                'houseNo': address?.houseNo,
                'street': address?.street,
                'barangay': address?.brgy,
                'zone': address?.zone,
                'city': address?.city,
                'province': address?.province,
                'zipCode': address?.zipCode,
                'country': address?.country ?? 'Philippines',
                'spouse_lastName': spouse?.lastName,
                'spouse_firstName': spouse?.firstName,
                'spouse_middleName': spouse?.middleName,
                'spouse_gender': spouse?.gender,
                'spouse_birthDate': spouse?.birthDate,
                'spouse_birthPlace': spouse?.birthPlace,
                'spouse_weight': spouse?.weight,
                'spouse_height': spouse?.height,
                'spouse_tinNo': spouse?.tinNo,
                'spouse_sssNo': spouse?.sssNo,
                'spouse_philHealthNo': spouse?.philHealthNo,
                'spouse_mobileNo': spouse?.mobileNumber,
                'spouse_telNo': spouse?.telNo,
                'spouse_email': spouse?.email,
                'ed_companyName': edUser?.companyName,
                'ed_natureOfBusiness': edUser?.natureOfBusiness,
                'ed_position': edUser?.position,
                'ed_yearsOfEmployment': edUser?.years.toString(),
                'ed_companyAddress': edUser?.address,
                'spouse_ed_companyName': edUserSpouse?.companyName,
                'spouse_ed_natureOfBusiness': edUserSpouse?.natureOfBusiness,
                'spouse_ed_position': edUserSpouse?.position,
                'spouse_ed_yearsOfEmployment': edUserSpouse?.years.toString(),
                'spouse_ed_companyAddress': edUserSpouse?.address,
              };

              if (state.showValues != null) {
                values.addAll(state.showValues!);
              }

              _formKey.currentState?.patchValue(values);
            }
          },
        ),
        BlocListener<LoanBloc, LoanState>(
          listener: (context, state) {
            if (state is LoanDisplaySummaryState) {
              _pagingController.value = PagingState(
                itemList: loanBloc.clientLoanSchedules,
              );
            } else if (state is LoanLoadingState) {
              if (!_showLoanLoadingDialog) {
                return;
              }

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
                            userBloc.tempUser?.completeName ?? 'User',
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
                pagingController: _pagingController,
                formKey: _formKey,
              )
            : buildLargeScreenBody(
                context: context,
                userId: widget.userId,
                isProfile: widget.isProfile,
                pagingController: _pagingController,
                formKey: _formKey,
              ),
      ),
    );
  }
}
