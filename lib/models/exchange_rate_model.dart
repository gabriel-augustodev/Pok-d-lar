class ExchangeRateModel {
  final double value;
  final String fromCurrency;
  final String toCurrency;

  const ExchangeRateModel({
    required this.value,
    required this.fromCurrency,
    required this.toCurrency,
  });

  String get formattedValue => 'R\$ ${value.toStringAsFixed(2)}';
  int get pokemonNumber => (value * 100).round();

  factory ExchangeRateModel.empty() {
    return const ExchangeRateModel(
      value: 0.0,
      fromCurrency: 'USD',
      toCurrency: 'BRL',
    );
  }
}
