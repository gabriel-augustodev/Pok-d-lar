class Helpers {
  static String formatPokemonNumber(int number) {
    return 'Nº ${number.toString().padLeft(4, '0')}';
  }

  static String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
  }
}
