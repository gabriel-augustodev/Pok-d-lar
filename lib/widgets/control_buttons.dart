import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/pokemon_model.dart';
import '../services/tts_service.dart';

class ControlButtons extends StatelessWidget {
  final PokemonModel pokemon;

  const ControlButtons({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          context,
          Icons.arrow_back,
          AppTheme.pokedexYellow,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        _buildButton(
          context,
          Icons.info_outline,
          AppTheme.pokedexLightBlue,
          onPressed: () async {
            // Mostrar indicador de que está falando
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Pokédex falando...'),
                  ],
                ),
                duration: Duration(seconds: 3),
              ),
            );

            // Falar as informações do Pokémon
            await TTSService.speakPokemonInfo(
              name: pokemon.name,
              type: pokemon.type,
              category: pokemon.category,
              description: pokemon.description,
            );
          },
        ),
        const SizedBox(width: 20),
        _buildButton(
          context,
          Icons.favorite_border,
          AppTheme.pokedexRed,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidade em desenvolvimento!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    Color color, {
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black26,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
