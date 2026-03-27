import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isSpeaking = false;

  static Future<void> speakPokemonInfo({
    required String name,
    required String type,
    required String category,
    required String description,
  }) async {
    try {
      // Para se já estiver falando
      if (_isSpeaking) {
        await _flutterTts.stop();
      }

      // Configurar idioma para português
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setSpeechRate(0.5); // Velocidade da fala (0.0-1.0)
      await _flutterTts.setPitch(1.0); // Tom da voz

      // Construir o texto que será lido
      String textToSpeak = _buildTextToSpeak(
        name: name,
        type: type,
        category: category,
        description: description,
      );

      // Iniciar a fala
      _isSpeaking = true;
      await _flutterTts.speak(textToSpeak);

      // Quando terminar de falar
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      // Em caso de erro
      _flutterTts.setErrorHandler((msg) {
        print('Erro no TTS: $msg');
        _isSpeaking = false;
      });
    } catch (e) {
      print('Erro ao falar: $e');
      _isSpeaking = false;
    }
  }

  static String _buildTextToSpeak({
    required String name,
    required String type,
    required String category,
    required String description,
  }) {
    // Remove "Pokémon " do início da categoria se existir
    String cleanCategory = category.replaceAll('Pokémon ', '');

    // Constrói a frase completa
    StringBuffer buffer = StringBuffer();

    buffer.write('$name, ');
    buffer.write('um Pokémon do tipo $type, ');

    if (cleanCategory.isNotEmpty && cleanCategory != name) {
      buffer.write('da categoria $cleanCategory, ');
    }

    buffer.write(description);

    return buffer.toString();
  }

  static Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }
}
