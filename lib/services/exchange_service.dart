import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeService {
  static const String _apiUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';
  static const Duration _timeout = Duration(seconds: 10);

  static Future<double> fetchDollarRate() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates']['BRL'] as double;
      } else {
        throw Exception('Erro ao obter cotação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
