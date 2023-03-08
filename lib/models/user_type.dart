enum UserType {
  customer('Customer'),
  admin('Administrator'),
  accountant('Accountant'),
  subAdmin('Assistant administrator');

  final String value;
  const UserType(this.value);
}