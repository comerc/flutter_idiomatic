import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  textTheme: GoogleFonts.openSansTextTheme(),
  primaryColorDark: Color(0xFF0097A7),
  primaryColorLight: Color(0xFFB2EBF2),
  primaryColor: Color(0xFF00BCD4),
  accentColor: Color(0xFF009688),
  scaffoldBackgroundColor: Color(0xFFE0F2F1),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
