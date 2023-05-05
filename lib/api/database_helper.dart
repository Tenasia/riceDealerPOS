import 'package:http/http.dart' as http;
import 'dart:convert';
class DatabaseHelper {

  static Future<List<dynamic>> getUsers() async {
    final response = await http.post(
      Uri.parse('http://192.168.68.112/rice-dealer/index.php/api/get_users'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final users = data['data'] as List<dynamic>;
      return users;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<dynamic>> getProducts() async {
    final response = await http.post(
      Uri.parse('http://192.168.68.112/rice-dealer/index.php/api/get_products'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['data'] as List<dynamic>;
      return products;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<void> sendDataToServer(Map<String, dynamic> data) async {
    final url = Uri.parse('http://192.168.68.112/rice-dealer/index.php/api/processCheckout');

    // Convert the data object to JSON
    String jsonData = jsonEncode(data);

    // Print the jsonData
    print('Sending data: $jsonData');

    final response = await http.post(
      url,
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Data sent successfully! Status code is 200!');
    } else {
      throw Exception('Failed to send data: ${response.statusCode}');
    }
  }

}
