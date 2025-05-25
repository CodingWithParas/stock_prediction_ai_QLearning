import 'dart:convert';
import 'package:http/http.dart' as http;

class QLearningService {
  final String _serverUrl = 'https://5736-2401-4900-5a53-9bbf-1c90-e8f-eafe-4003.ngrok-free.app/predict';

  Future<String?> getActionFromPrice(double price) async {
    final response = await http.post(
      Uri.parse(_serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'price': price}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['action'];
    } else {
      print("Error: ${response.body}");
      return null;
    }
  }
}
