enum UserType {
  customer('Customer'),
  admin('Administrator'),
  agent('Agent'),
  accountant('Accountant'),
  subAdmin('Assistant administrator');

  final String value;
  const UserType(this.value);
}