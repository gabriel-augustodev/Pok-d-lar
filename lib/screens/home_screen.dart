import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/exchange_service.dart';
import '../services/pokemon_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pokedex_app_bar.dart';
import '../widgets/lights_decorative.dart';
import '../widgets/pokedex_card.dart';

import '../widgets/exchange_card.dart';
import '../widgets/control_buttons.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _dolarValue = 0.0;
  int _pokemonNumber = 0;
  PokemonModel _pokemon = PokemonModel.empty();
  bool _isLoading = true;
  bool _isLoadingPokemon = false;
  bool _isTranslating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isTranslating = true;
    });

    try {
      _dolarValue = await ExchangeService.fetchDollarRate();
      _pokemon = await PokemonService.getPokemonByRate(_dolarValue);
      _pokemonNumber = _pokemon.number;
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados. Verifique sua conexão.';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pokedexRed,
      body: SafeArea(
        child: Column(
          children: [
            const PokedexAppBar(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
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
                        const LightsDecorative(),
                        Expanded(
                          child: _isLoading
                              ? const LoadingWidget()
                              : _errorMessage != null
                                  ? CustomErrorWidget(
                                      message: _errorMessage!,
                                      onRetry: _loadData,
                                    )
                                  : _buildContent(),
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
        onPressed: _loadData,
        backgroundColor: AppTheme.pokedexLightBlue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          PokemonCard(
            pokemon: _pokemon,
            isLoadingPokemon: _isLoadingPokemon,
            pokemonNumber: _pokemonNumber,
          ),
          const SizedBox(height: 20),
          ExchangeCard(
            dolarValue: _dolarValue,
            pokemonDescription: _pokemon.description,
            pokemonCategory: _pokemon.category,
            isTranslating: _isTranslating,
          ),
          const SizedBox(height: 20),
          const ControlButtons(),
        ],
      ),
    );
  }
}
