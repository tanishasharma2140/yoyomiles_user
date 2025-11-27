// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yoyomiles/model/packer_mover_model.dart';

class ApiService {
  final String baseUrl = 'https://admin.yoyomiles.com';

  Future<PackerMoversModel> getPackerMoverItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/packer_and_mover'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PackerMoversModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }
}