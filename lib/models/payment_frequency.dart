enum PaymentFrequency {
  monthly('Monthly'),
  biMonthly('Twice a month');

  final String label;

  const PaymentFrequency(this.label);
}