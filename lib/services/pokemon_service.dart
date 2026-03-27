import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';
import 'translation_service.dart';

class PokemonService {
  static const String _pokemonApiUrl = 'https://pokeapi.co/api/v2/pokemon/';
  static const String _speciesApiUrl =
      'https://pokeapi.co/api/v2/pokemon-species/';
  static const Duration _timeout = Duration(seconds: 10);

  // Tradução dos tipos para português
  static const Map<String, String> _typeTranslations = {
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

  static Future<PokemonModel> getPokemonByRate(double rate) async {
    int pokemonNumber = (rate * 100).round();

    // Garantir que está dentro dos limites (1-1025)
    if (pokemonNumber < 1) pokemonNumber = 1;
    if (pokemonNumber > 1025) pokemonNumber = 1025;

    final pokemonData = await _fetchPokemonData(pokemonNumber);
    final speciesData = await _fetchSpeciesData(pokemonNumber);

    final name = _formatName(pokemonData['name']);
    final type = _formatTypes(pokemonData['types']);
    final imageUrl = _getImageUrl(pokemonData);
    final category = await _getCategory(speciesData);
    final description = await _getDescription(speciesData);

    return PokemonModel(
      number: pokemonNumber,
      name: name,
      imageUrl: imageUrl,
      type: type,
      category: category,
      description: description,
    );
  }

  static Future<Map<String, dynamic>> _fetchPokemonData(int number) async {
    final response =
        await http.get(Uri.parse('$_pokemonApiUrl$number')).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar Pokémon');
    }
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> _fetchSpeciesData(int number) async {
    final response =
        await http.get(Uri.parse('$_speciesApiUrl$number')).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar dados da espécie');
    }
    return json.decode(response.body);
  }

  static String _formatName(dynamic rawName) {
    final name = rawName as String;
    return name[0].toUpperCase() + name.substring(1);
  }

  static String _formatTypes(List<dynamic> types) {
    final typeNames =
        types.map((type) => type['type']['name'].toString()).toList();

    return typeNames
        .map((t) => _typeTranslations[t] ?? t[0].toUpperCase() + t.substring(1))
        .join(' / ');
  }

  static String _getImageUrl(Map<String, dynamic> data) {
    return data['sprites']['other']['official-artwork']['front_default'] ??
        data['sprites']['front_default'];
  }

  static Future<String> _getCategory(Map<String, dynamic> speciesData) async {
    final genera = speciesData['genera'] as List;

    // Tenta português do Brasil
    var genus = genera.firstWhere(
      (g) => g['language']['name'] == 'pt-BR',
      orElse: () => null,
    );

    if (genus == null) {
      // Tenta espanhol
      genus = genera.firstWhere(
        (g) => g['language']['name'] == 'es',
        orElse: () => null,
      );
    }

    if (genus != null) {
      String category = genus['genus']
          .toString()
          .replaceAll('Pokémon', '')
          .replaceAll('Pokemon', '')
          .trim();
      category = TranslationService.fixPortugueseSpelling(category);
      return 'Pokémon $category';
    }

    // Fallback para inglês traduzido
    final englishGenus = genera.firstWhere(
      (g) => g['language']['name'] == 'en',
      orElse: () => null,
    );

    if (englishGenus != null) {
      String englishCategory = englishGenus['genus']
          .toString()
          .replaceAll('Pokémon', '')
          .replaceAll('Pokemon', '')
          .trim();
      final translated =
          await TranslationService.translateCategory(englishCategory);
      return 'Pokémon $translated';
    }

    return 'Pokémon';
  }

  static Future<String> _getDescription(
      Map<String, dynamic> speciesData) async {
    final flavorTexts = speciesData['flavor_text_entries'] as List;

    // Tenta português do Brasil
    var entry = flavorTexts.firstWhere(
      (e) => e['language']['name'] == 'pt-BR',
      orElse: () => null,
    );

    if (entry == null) {
      // Tenta português de Portugal
      entry = flavorTexts.firstWhere(
        (e) => e['language']['name'] == 'pt',
        orElse: () => null,
      );
    }

    if (entry != null) {
      return entry['flavor_text']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\f', ' ');
    }

    // Fallback para inglês traduzido
    final englishEntry = flavorTexts.firstWhere(
      (e) => e['language']['name'] == 'en',
      orElse: () => null,
    );

    if (englishEntry != null) {
      String englishText = englishEntry['flavor_text']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\f', ' ');

      String translated =
          await TranslationService.translateWithMultipleAPIs(englishText);
      return TranslationService.fixPortugueseSpelling(translated);
    }

    return 'Descrição não disponível para este Pokémon.';
  }
}
