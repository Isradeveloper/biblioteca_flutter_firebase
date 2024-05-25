class AppRegex {
  const AppRegex._();

  static final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.([a-zA-Z]{2,})+");
  static final RegExp sevenMinRegex = RegExp(r'^.{7,}$');
  static final RegExp positiveNumberRegex = RegExp(r'^\d*\.?\d+$');
}
