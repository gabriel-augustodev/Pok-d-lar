import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class PokemonCard extends StatelessWidget {
  final PokemonModel pokemon;
  final bool isLoadingPokemon;
  final int pokemonNumber;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.isLoadingPokemon,
    required this.pokemonNumber,
  });

  Color _getTypeColor(String type) {
    final Map<String, String> typeTranslations = {
      'normal': 'Normal',
      'fire': 'Fogo',
      'water': 'Água',
      'electric': 'Elétrico',
      'grass': 'Grama',
      'ice': 'Gelo',
      'fighting': 'Lutador',
      'poison': 'Venenoso',
      'ground': 'Terrestre',
      'flying': 'Voador',
      'psychic': 'Psíquico',
      'bug': 'Inseto',
      'rock': 'Pedra',
      'ghost': 'Fantasma',
      'dragon': 'Dragão',
      'dark': 'Sombrio',
      'steel': 'Metálico',
      'fairy': 'Fada',
    };

    final Map<String, String> reverseTranslation = {};
    typeTranslations.forEach((key, value) {
      reverseTranslation[value.toLowerCase()] = key;
    });

    String mainType = type.split(' / ')[0].toLowerCase();
    String englishType = reverseTranslation[mainType] ?? mainType;

    switch (englishType) {
      case 'normal':
        return Colors.grey[400]!;
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'electric':
        return Colors.yellow[700]!;
      case 'grass':
        return Colors.green;
      case 'ice':
        return Colors.lightBlue;
      case 'fighting':
        return Colors.brown;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown[300]!;
      case 'flying':
        return Colors.indigo[200]!;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen;
      case 'rock':
        return Colors.grey[600]!;
      case 'ghost':
        return Colors.deepPurple;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.grey[850]!;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pink[100]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppTheme.pokedexGray, width: 2),
      ),
      child: Column(
        children: [
          // Header cinza com número
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.pokedexGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                Helpers.formatPokemonNumber(pokemonNumber),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // Imagem do Pokémon
          Container(
            padding: const EdgeInsets.all(20),
            child: isLoadingPokemon
                ? SizedBox(
                    height: 150,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.pokedexLightBlue),
                      ),
                    ),
                  )
                : Image.network(
                    pokemon.imageUrl,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonNumber.png',
                        height: 150,
                      );
                    },
                  ),
          ),
          // Nome do Pokémon
          Text(
            pokemon.name.isNotEmpty ? pokemon.name : '???',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.pokedexDarkRed,
            ),
          ),
          // Tipo do Pokémon
          if (pokemon.type.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: _getTypeColor(pokemon.type),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pokemon.type,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
