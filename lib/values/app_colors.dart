import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();
  static const Color primaryColor = Color.fromARGB(255, 0, 255, 127);
  static const Color primaryDarkColor = Color.fromARGB(255, 0, 124, 62);
  // static const Color primaryDarkColor = Color.fromARGB(255, 80, 96, 42);
  static const Color darkBlue = Color.fromARGB(255, 30, 46, 61);
  static const Color darkerBlue = Color.fromARGB(255, 21, 37, 52);
  static const Color darkestBlue = Color.fromARGB(255, 12, 28, 46);
  static const Color greenSpring = Color.fromARGB(255, 0, 255, 127);

  static const List<Color> defaultGradient = [
    darkBlue,
    darkerBlue,
    darkestBlue,
  ];
}
