enum CivilStatus {
  single('Single'),
  married('Married'),
  divorced('Divorced');

  final String value;
  const CivilStatus(this.value);
}