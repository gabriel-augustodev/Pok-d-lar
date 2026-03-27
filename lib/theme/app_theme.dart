import 'package:flutter/material.dart';

class AppTheme {
  // Cores da Pokédex (visual do Boldore)
  static const Color pokedexRed = Color(0xFFDC0A2D);
  static const Color pokedexDarkRed = Color(0xFFB10D2A);
  static const Color pokedexLightBlue = Color(0xFF30A7D7);
  static const Color pokedexYellow = Color(0xFFFFCB05);
  static const Color pokedexGray = Color(0xFF9199A1);
  static const Color white = Colors.white;
  static const Color black26 = Colors.black26;
  static const Color grey700 = Color(0xFF616161);

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.red,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: pokedexRed,
    );
  }
}
