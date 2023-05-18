import 'package:flutter/material.dart';

const black = Color(0xFF101823);
const white = Color(0xFFFFFFFF);
const grey = Color(0xFF787878);

class AppTheme {
  final dailyStoreTheme = ThemeData(
    scaffoldBackgroundColor: black,
    appBarTheme:
        const AppBarTheme(backgroundColor: Colors.transparent, elevation: 5),
  );
}
