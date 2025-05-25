import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService{
  final String _apiKey = "M831TAEL312V5ZZC";

  Future<Map<String, dynamic>?> fetchStockData(String symbol) async {
    final url = Uri.parse(
      'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$symbol&interval=5min&apikey=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200 ){
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData.containsKey('Time Series (5min)')) {
        return jsonData['Time Series (5min)'];
      } else {
        print("Error: ${jsonData['Note'] ?? 'Unexpected format'}");
        return null;
      }
    } else {
      print("Failed to load data: ${response.statusCode}");
      return null;
    }
  }
}