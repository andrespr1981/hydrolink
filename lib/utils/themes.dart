import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  // Ghost white
  scaffoldBackgroundColor: Color.fromARGB(255, 248, 248, 255),
  colorScheme: ColorScheme.light(onPrimaryContainer: Colors.white),
);

//https://www.vev.design/blog/dark-mode-website-color-palette/ es la monochromatic
final ThemeData darkTheme = ThemeData(
  // Charcoal black
  scaffoldBackgroundColor: Color.fromARGB(255, 33, 33, 33),
  colorScheme: ColorScheme.dark(
    onPrimaryContainer: const Color.fromARGB(255, 169, 169, 169),
  ),
);
