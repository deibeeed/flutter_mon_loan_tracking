part of 'user_details_screen.dart';

/// show update button if user is
/// detail is the current user or
/// if user is subadmin
bool shouldShowUpdateButton({
  required BuildContext context,
  required String? userId,
}) {
  final userBloc = BlocProvider.of<UserBloc>(context);

  if (userBloc.getLoggedInUser() != null &&
      [UserType.admin, UserType.subAdmin]
          .contains(userBloc.getLoggedInUser()!.type)) {
    return true;
  }

  if (userId != null && userBloc.getLoggedInUser() != null) {
    return userId == userBloc.getLoggedInUser()!.id;
  }

  return false;
}
