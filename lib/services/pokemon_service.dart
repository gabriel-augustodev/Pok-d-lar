import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';
import '../utils/constants.dart';
import 'translation_service.dart';

class PokemonService {
  static final Map<String, String> _typeTranslations = {
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

    if (pokemonNumber < ApiConstants.minPokemonNumber)
      pokemonNumber = ApiConstants.minPokemonNumber;
    if (pokemonNumber > ApiConstants.maxPokemonNumber)
      pokemonNumber = ApiConstants.maxPokemonNumber;

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
    final response = await http
        .get(Uri.parse('${ApiConstants.pokeApiBaseUrl}/pokemon/$number'))
        .timeout(ApiConstants.apiTimeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar Pokémon');
    }
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> _fetchSpeciesData(int number) async {
    final response = await http
        .get(Uri.parse(
            '${ApiConstants.pokeApiBaseUrl}/pokemon-species/$number/'))
        .timeout(ApiConstants.apiTimeout);

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

    // Tenta português do Brasil primeiro
    var genus = genera.firstWhere(
      (g) => g['language']['name'] == 'pt-BR',
      orElse: () => null,
    );

    if (genus != null) {
      String category = genus['genus']
          .toString()
          .replaceAll('Pokémon', '')
          .replaceAll('Pokemon', '')
          .trim();
      category = TranslationService.fixPortugueseSpelling(category);
      return 'Pokémon $category';
    }

    // Tenta espanhol
    genus = genera.firstWhere(
      (g) => g['language']['name'] == 'es',
      orElse: () => null,
    );

    if (genus != null) {
      String spanishCategory = genus['genus']
          .toString()
          .replaceAll('Pokémon', '')
          .replaceAll('Pokemon', '')
          .trim();

      print('Categoria em espanhol: $spanishCategory'); // Para debug

      // Traduz do espanhol para português
      String translated = await _translateSpanishToPortuguese(spanishCategory);
      translated = TranslationService.fixPortugueseSpelling(translated);
      print('Categoria traduzida: $translated'); // Para debug

      return 'Pokémon $translated';
    }

    // Fallback para inglês
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

      String translated =
          await TranslationService.translateCategory(englishCategory);
      translated = TranslationService.fixPortugueseSpelling(translated);
      return 'Pokémon $translated';
    }

    return 'Pokémon';
  }

  // Função específica para traduzir do espanhol para português
  static Future<String> _translateSpanishToPortuguese(
      String spanishText) async {
    // Mapeamento direto para palavras comuns em espanhol
    final Map<String, String> spanishToPortuguese = {
      'Rayo': 'Raio',
      'Rayo Pokémon': 'Raio Pokémon',
      'Pokémon Rayo': 'Pokémon Raio',
      'Electrizado': 'Eletrizado',
      'Pokémon Electrizado': 'Pokémon Eletrizado',
      'Flama': 'Chama',
      'Agua': 'Água',
      'Tierra': 'Terra',
      'Aire': 'Ar',
      'Fuego': 'Fogo',
      'Planta': 'Planta',
      'Veneno': 'Veneno',
      'Psíquico': 'Psíquico',
      'Hielo': 'Gelo',
      'Dragón': 'Dragão',
      'Siniestro': 'Sombrio',
      'Acero': 'Metálico',
      'Hada': 'Fada',
    };

    // Verifica se tem tradução direta
    if (spanishToPortuguese.containsKey(spanishText)) {
      return spanishToPortuguese[spanishText]!;
    }

    // Verifica se contém alguma palavra conhecida
    for (var entry in spanishToPortuguese.entries) {
      if (spanishText.contains(entry.key)) {
        return spanishText.replaceAll(entry.key, entry.value);
      }
    }

    // Se não encontrar, tenta tradução automática
    try {
      // Usa a API do LibreTranslate para espanhol -> português
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': spanishText,
          'source': 'es',
          'target': 'pt',
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translatedText'];
      }
    } catch (e) {
      print('Erro na tradução do espanhol: $e');
    }

    return spanishText;
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
