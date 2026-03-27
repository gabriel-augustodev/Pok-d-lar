import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // Função para corrigir ortografia em português
  static String fixPortugueseSpelling(String text) {
    return text
        .replaceAll('Electrizado', 'Eletrizado')
        .replaceAll('ELECTRIZADO', 'ELETRIZADO')
        .replaceAll('electrizado', 'eletrizado')
        .replaceAll('Electrizada', 'Eletrizada')
        .replaceAll('ELECTRIZADA', 'ELETRIZADA')
        .replaceAll('electrizada', 'eletrizada')
        .replaceAll('Rayo', 'Raio')
        .replaceAll('RAYO', 'RAIO')
        .replaceAll('rayo', 'raio')
        .replaceAll('Electrico', 'Elétrico')
        .replaceAll('ELECTRICO', 'ELÉTRICO')
        .replaceAll('electrico', 'elétrico')
        .replaceAll('eletrico', 'elétrico')
        .replaceAll('Eletrico', 'Elétrico')
        .replaceAll('ELETRICO', 'ELÉTRICO')
        .replaceAll('Flama', 'Chama')
        .replaceAll('flama', 'chama')
        .replaceAll('Tierra', 'Terra')
        .replaceAll('tierra', 'terra')
        .replaceAll('Agua', 'Água')
        .replaceAll('agua', 'água');
  }

  // Mapeamento de categorias comuns para tradução rápida
  static const Map<String, String> _commonCategories = {
    'Seed': 'Semente',
    'Lizard': 'Lagarto',
    'Flame': 'Chama',
    'Tiny Turtle': 'Tartaruguinha',
    'Turtle': 'Tartaruga',
    'Shellfish': 'Marisco',
    'Worm': 'Verme',
    'Cocoon': 'Casulo',
    'Butterfly': 'Borboleta',
    'Hairy Bug': 'Inseto Peludo',
    'Poison Bee': 'Abelha Venenosa',
    'Tiny Bird': 'Passarinho',
    'Bird': 'Pássaro',
    'Electric': 'Elétrico',
    'Electrified': 'Eletrizado',
    'Mouse': 'Rato',
    'Beak': 'Bico',
    'Snake': 'Cobra',
    'Cobra': 'Naja',
    'Poison Pin': 'Espinho Venenoso',
    'Drill': 'Broca',
    'Fairy': 'Fada',
    'Fox': 'Raposa',
    'Balloon': 'Balão',
    'Bat': 'Morcego',
    'Mushroom': 'Cogumelo',
    'Bug Catcher': 'Coletor de Insetos',
    'Tadpole': 'Girino',
    'Armor': 'Armadura',
    'Spikes': 'Espinhos',
    'Magnet': 'Ímã',
    'Kissing': 'Beijo',
    'Mime': 'Mímico',
    'Shape-Shifter': 'Transformista',
    'Barrier': 'Barreira',
    'Megaton': 'Megatonelada',
    'Mythical': 'Mítico',
    'Legendary': 'Lendário',
    'Thunderbolt': 'Raio',
    'Lightning': 'Relâmpago',
    'Bolt': 'Raio',
  };

  static Future<String> translateCategory(String englishCategory) async {
    // Verifica no dicionário primeiro
    if (_commonCategories.containsKey(englishCategory)) {
      return _commonCategories[englishCategory]!;
    }

    // Tenta traduzir automaticamente
    String translated = await translateWithMultipleAPIs(englishCategory);
    return fixPortugueseSpelling(translated);
  }

  static Future<String> translateWithMultipleAPIs(String text) async {
    final List<Future<String?>> translationAttempts = [
      _translateWithLibreTranslate(text),
      _translateWithMyMemory(text),
      _translateWithLingva(text),
    ];

    for (var attempt in translationAttempts) {
      try {
        final result = await attempt.timeout(const Duration(seconds: 5));
        if (result != null && result.isNotEmpty && result != text) {
          return result;
        }
      } catch (e) {
        continue;
      }
    }
    return text;
  }

  static Future<String?> _translateWithLibreTranslate(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': text,
          'source': 'en',
          'target': 'pt',
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translatedText'];
      }
    } catch (e) {}
    return null;
  }

  static Future<String?> _translateWithMyMemory(String text) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|pt'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['responseData'] != null &&
            data['responseData']['translatedText'] != null) {
          return data['responseData']['translatedText'];
        }
      }
    } catch (e) {}
    return null;
  }

  static Future<String?> _translateWithLingva(String text) async {
    try {
      final response = await http.get(Uri.parse(
          'https://lingva.ml/api/v1/en/pt/${Uri.encodeComponent(text)}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translation'];
      }
    } catch (e) {}
    return null;
  }
}
