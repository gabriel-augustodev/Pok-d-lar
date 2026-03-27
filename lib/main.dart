import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeDólar - Pokédex',
      theme: AppTheme.lightTheme,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
