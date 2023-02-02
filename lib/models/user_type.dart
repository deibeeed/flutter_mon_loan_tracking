enum UserType {
  customer('Customer'),
  admin('Administrator'),
  agent('Agent'),
  accountant('Accountant');

  final String value;
  const UserType(this.value);
}