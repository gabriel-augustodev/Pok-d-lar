import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeDólar - Pokédex',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double dolarValue = 0.0;
  int pokemonNumber = 0;
  String pokemonName = '';
  String pokemonImageUrl = '';
  String pokemonType = '';
  String pokemonDescription = '';
  bool isLoading = true;
  bool isLoadingPokemon = false;
  bool isTranslating = false;
  String? errorMessage;

  // Tradução dos tipos para português
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

  // Cores da Pokédex
  final Color pokedexRed = Color(0xFFDC0A2D);
  final Color pokedexDarkRed = Color(0xFFB10D2A);
  final Color pokedexLightBlue = Color(0xFF30A7D7);
  final Color pokedexYellow = Color(0xFFFFCB05);
  final Color pokedexGray = Color(0xFF9199A1);

  @override
  void initState() {
    super.initState();
    fetchDolarValue();
  }

  Future<void> fetchDolarValue() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          dolarValue = data['rates']['BRL'];
        });
        await convertToPokemon();
      } else {
        setState(() {
          errorMessage = 'Erro ao obter a cotação';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro de conexão';
        isLoading = false;
      });
    }
  }

  Future<void> convertToPokemon() async {
    setState(() {
      isLoadingPokemon = true;

      // CORREÇÃO: O número do Pokémon é a cotação * 100 (sem o +1)
      // R$ 5.18 → 518 → Pokémon #518 (Musharna)
      // R$ 4.86 → 486 → Pokémon #486 (Regigigas)
      pokemonNumber = (dolarValue * 100).round();

      // Garantir que está dentro dos limites (1-1025)
      if (pokemonNumber < 1) pokemonNumber = 1;
      if (pokemonNumber > 1025) pokemonNumber = 1025;
    });

    try {
      // Busca dados do Pokémon
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonNumber'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawName = data['name'] as String;
        final formattedName = rawName[0].toUpperCase() + rawName.substring(1);

        // Pega os tipos e traduz para português
        final types = (data['types'] as List)
            .map((type) => type['type']['name'].toString())
            .toList();
        final formattedTypes = types
            .map((t) =>
                typeTranslations[t] ?? t[0].toUpperCase() + t.substring(1))
            .join(' / ');

        // Pega a imagem oficial
        String imageUrl = data['sprites']['other']['official-artwork']
                ['front_default'] ??
            data['sprites']['front_default'];

        setState(() {
          pokemonName = formattedName;
          pokemonImageUrl = imageUrl;
          pokemonType = formattedTypes;
        });

        // Busca a descrição do Pokémon
        await getPokemonDescription(pokemonNumber);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar Pokémon';
        isLoading = false;
        isLoadingPokemon = false;
      });
    }
  }

  Future<void> getPokemonDescription(int number) async {
    setState(() {
      isTranslating = true;
    });

    try {
      final speciesResponse = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$number/'))
          .timeout(Duration(seconds: 10));

      if (speciesResponse.statusCode == 200) {
        final speciesData = json.decode(speciesResponse.body);
        final flavorTexts = speciesData['flavor_text_entries'] as List;

        // Tenta português do Brasil primeiro
        final portugueseEntry = flavorTexts.firstWhere(
          (entry) => entry['language']['name'] == 'pt-BR',
          orElse: () => null,
        );

        if (portugueseEntry != null) {
          setState(() {
            pokemonDescription = portugueseEntry['flavor_text']
                .toString()
                .replaceAll('\n', ' ')
                .replaceAll('\f', ' ');
            isLoading = false;
            isLoadingPokemon = false;
            isTranslating = false;
          });
          return;
        }

        // Tenta português de Portugal
        final portugalEntry = flavorTexts.firstWhere(
          (entry) => entry['language']['name'] == 'pt',
          orElse: () => null,
        );

        if (portugalEntry != null) {
          setState(() {
            pokemonDescription = portugalEntry['flavor_text']
                .toString()
                .replaceAll('\n', ' ')
                .replaceAll('\f', ' ');
            isLoading = false;
            isLoadingPokemon = false;
            isTranslating = false;
          });
          return;
        }

        // Se não achar português, pega inglês e traduz
        final englishEntry = flavorTexts.firstWhere(
          (entry) => entry['language']['name'] == 'en',
          orElse: () => null,
        );

        if (englishEntry != null) {
          String englishText = englishEntry['flavor_text']
              .toString()
              .replaceAll('\n', ' ')
              .replaceAll('\f', ' ');

          // Tenta traduzir com múltiplas APIs
          String translatedText = await translateWithMultipleAPIs(englishText);

          setState(() {
            pokemonDescription = translatedText;
            isLoading = false;
            isLoadingPokemon = false;
            isTranslating = false;
          });
          return;
        }
      }

      // Se não encontrou nenhuma descrição
      setState(() {
        pokemonDescription = 'Descrição não disponível para este Pokémon.';
        isLoading = false;
        isLoadingPokemon = false;
        isTranslating = false;
      });
    } catch (e) {
      setState(() {
        pokemonDescription = 'Erro ao carregar descrição.';
        isLoading = false;
        isLoadingPokemon = false;
        isTranslating = false;
      });
    }
  }

  Future<String> translateWithMultipleAPIs(String text) async {
    // Lista de APIs de tradução gratuitas para tentar
    final List<Future<String?>> translationAttempts = [
      translateWithLibreTranslate(text),
      translateWithMyMemory(text),
      translateWithLingva(text),
    ];

    // Tenta cada API até uma funcionar
    for (var attempt in translationAttempts) {
      try {
        final result = await attempt.timeout(Duration(seconds: 5));
        if (result != null && result.isNotEmpty && result != text) {
          print('Tradução bem-sucedida!');
          return result;
        }
      } catch (e) {
        print('Tentativa falhou: $e');
        continue;
      }
    }

    // Se todas falharem, retorna o texto original
    print('Todas as traduções falharam');
    return text;
  }

  Future<String?> translateWithLibreTranslate(String text) async {
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
    } catch (e) {
      print('LibreTranslate erro: $e');
    }
    return null;
  }

  Future<String?> translateWithMyMemory(String text) async {
    try {
      // MyMemory - API de tradução gratuita
      final response = await http.get(Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|pt'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['responseData'] != null &&
            data['responseData']['translatedText'] != null) {
          return data['responseData']['translatedText'];
        }
      }
    } catch (e) {
      print('MyMemory erro: $e');
    }
    return null;
  }

  Future<String?> translateWithLingva(String text) async {
    try {
      // Lingva Translate (instância pública)
      final response = await http.get(Uri.parse(
          'https://lingva.ml/api/v1/en/pt/${Uri.encodeComponent(text)}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translation'];
      }
    } catch (e) {
      print('Lingva erro: $e');
    }
    return null;
  }

  Color _getTypeColor(String type) {
    String mainType = type.split(' / ')[0].toLowerCase();

    // Converte o tipo em português para inglês para pegar a cor
    final Map<String, String> reverseTranslation = {};
    typeTranslations.forEach((key, value) {
      reverseTranslation[value.toLowerCase()] = key;
    });

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
    return Scaffold(
      backgroundColor: pokedexRed,
      body: SafeArea(
        child: Column(
          children: [
            // Topo da Pokédex
            _buildTopScreen(),

            // Corpo principal
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.grey[100]!, Colors.white],
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildLights(),
                        Expanded(
                          child: isLoading && dolarValue == 0
                              ? _buildLoadingContent()
                              : errorMessage != null
                                  ? _buildErrorContent()
                                  : _buildPokedexContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchDolarValue,
        backgroundColor: pokedexLightBlue,
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildTopScreen() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pokedexLightBlue,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          _buildLight(Colors.yellow),
          _buildLight(Colors.green),
          _buildLight(Colors.red),
          Spacer(),
          Text(
            'POKÉDEX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLight(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }

  Widget _buildLights() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
          SizedBox(width: 5),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow,
            ),
          ),
          SizedBox(width: 5),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
            height: 80,
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(pokedexLightBlue),
          ),
          SizedBox(height: 20),
          Text(
            'BUSCANDO DADOS...',
            style: TextStyle(
              color: pokedexGray,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: pokedexRed,
          ),
          SizedBox(height: 20),
          Text(
            errorMessage!,
            style: TextStyle(fontSize: 16, color: pokedexGray),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchDolarValue,
            style: ElevatedButton.styleFrom(
              backgroundColor: pokedexLightBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('TENTAR NOVAMENTE'),
          ),
        ],
      ),
    );
  }

  Widget _buildPokedexContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
              border: Border.all(color: pokedexGray, width: 2),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: pokedexGray,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Nº ${pokemonNumber.toString().padLeft(4, '0')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: isLoadingPokemon
                      ? Container(
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  pokedexLightBlue),
                            ),
                          ),
                        )
                      : Image.network(
                          pokemonImageUrl,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonNumber.png',
                              height: 150,
                            );
                          },
                        ),
                ),
                Text(
                  pokemonName.isNotEmpty ? pokemonName : '???',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: pokedexDarkRed,
                  ),
                ),
                if (pokemonType.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getTypeColor(pokemonType),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pokemonType,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: 10),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: pokedexLightBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'COTAÇÃO DO DÓLAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${dolarValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pokemonDescription.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        if (isTranslating)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      pokedexLightBlue),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Traduzindo...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: pokedexGray,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        if (!isTranslating)
                          Text(
                            pokemonDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.arrow_back, pokedexYellow),
              SizedBox(width: 20),
              _buildControlButton(Icons.info_outline, pokedexLightBlue),
              SizedBox(width: 20),
              _buildControlButton(Icons.favorite_border, pokedexRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Funcionalidade em desenvolvimento!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
