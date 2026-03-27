class ApiConstants {
  static const String exchangeApiUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';
  static const String pokeApiBaseUrl = 'https://pokeapi.co/api/v2';
  static const Duration apiTimeout = Duration(seconds: 10);

  static const int minPokemonNumber = 1;
  static const int maxPokemonNumber = 1025;
}
