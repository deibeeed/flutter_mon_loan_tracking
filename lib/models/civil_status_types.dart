enum CivilStatus {
  single('Single'),
  married('Married'),
  divorced('Divorced'),
  widow('Widow'),
  widower('Widower'),
  annulled('Annulled'),
  separated('Separated');

  final String value;
  const CivilStatus(this.value);
}
