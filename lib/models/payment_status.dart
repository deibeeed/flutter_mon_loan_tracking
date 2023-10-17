/// payment status used for UI
///   // paid - green
//   // delayed - red
//   // on time - grey
enum PaymentStatus {
  paid('Paid'),
  overdue('Overdue'),
  nextPayment('Next'),
  all('All');

  final String value;

  const PaymentStatus(this.value);
}