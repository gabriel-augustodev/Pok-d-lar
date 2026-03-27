import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
            height: 80,
          ),
          const SizedBox(height: 20),
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppTheme.pokedexLightBlue),
          ),
          const SizedBox(height: 20),
          const Text(
            'BUSCANDO DADOS...',
            style: TextStyle(
              color: AppTheme.pokedexGray,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
