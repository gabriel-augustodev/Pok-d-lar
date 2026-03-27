import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class ExchangeCard extends StatelessWidget {
  final double dolarValue;
  final String pokemonDescription;
  final String pokemonCategory;
  final bool isTranslating;

  const ExchangeCard({
    super.key,
    required this.dolarValue,
    required this.pokemonDescription,
    required this.pokemonCategory,
    required this.isTranslating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black26,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header azul com cotação
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.pokedexLightBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'COTAÇÃO DO DÓLAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helpers.formatCurrency(dolarValue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          // Categoria do Pokémon (se existir)
          if (pokemonCategory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
              child: Text(
                pokemonCategory.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.pokedexDarkRed,
                  letterSpacing: 1,
                ),
              ),
            ),
          // Descrição do Pokémon
          if (pokemonDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
              child: isTranslating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.pokedexLightBlue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Traduzindo...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.pokedexGray,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      pokemonDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.grey700,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
        ],
      ),
    );
  }
}
