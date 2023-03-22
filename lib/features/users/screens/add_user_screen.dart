import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/civil_status_types.dart';
import 'package:flutter_mon_loan_tracking/models/employment_details.dart';
import 'package:flutter_mon_loan_tracking/models/gender.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

part 'add_user_screen_small.dart';

part 'add_user_screen_large.dart';

class AddUserScreen extends StatefulWidget {
  AddUserScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final birthDateController = TextEditingController();
  final middleNameController = TextEditingController();
  final birthPlaceController = TextEditingController();
  final nationalityController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final childrenCountController = TextEditingController();
  final tinNoController = TextEditingController();
  final sssNoController = TextEditingController();
  final philHealthController = TextEditingController();
  final telNoController = TextEditingController();

  final _formKey = GlobalKey<FormBuilderState>(debugLabel: 'add_user_screen');

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().initializeAddUser();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    final width = screenSize.width;
    final computedWidth = width * 0.88;
    var appBarHeight = screenSize.height * 0.16;
    var appBarBottomPadding = 48.0;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var titleTextStyle = Theme.of(context).textTheme.displaySmall;
    var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
    var avatarSize = 56.0;

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      appBarBottomPadding = 24;
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      titleTextStyle = Theme.of(context).textTheme.headlineMedium;
      avatarTextStyle = Theme.of(context).textTheme.titleSmall;
      avatarSize = 48;
    }

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoadingState) {
          if (state.isLoading) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const AlertDialog(
                    content: SizedBox(
                      width: 56,
                      height: 56,
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
        } else if (state is UserSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        } else if (state is UserErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is CloseScreenState) {
          GoRouter.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: !widget.isMobile()
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight),
                child: AppBar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.48),
                  leading: !widget.isMobile()
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
                            'Add user',
                            style: titleTextStyle?.apply(color: Colors.white),
                          ),
                          SizedBox(
                            width: avatarSize,
                            height: avatarSize,
                            child: InkWell(
                              onTap: () {
                                final user =
                                    context.read<UserBloc>().getLoggedInUser();
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
                                    context
                                            .read<UserBloc>()
                                            .getLoggedInUser()
                                            ?.initials ??
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
                lastNameController: lastNameController,
                firstNameController: firstNameController,
                mobileNumberController: mobileNumberController,
                emailController: emailController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                birthDateController: birthDateController,
                middleNameController: middleNameController,
                birthPlaceController: birthPlaceController,
                nationalityController: nationalityController,
                heightController: heightController,
                weightController: weightController,
                childrenCountController: childrenCountController,
                tinNoController: tinNoController,
                sssNoController: sssNoController,
                philHealthController: philHealthController,
                telNoController: telNoController,
              )
            : buildLargeScreenBody(context: context, formKey: _formKey),
      ),
    );
  }
}
