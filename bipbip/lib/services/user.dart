import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bipbip/models/user.dart';

class UserService {
  final String baseUrl = "http://10.60.116.151:8080/v1/bipbip";

  Future<User?> getUserById(int id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/user/$id'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return User.fromJson(decoded[0] as Map<String, dynamic>);
        }
        if (decoded is Map<String, dynamic> && decoded['id'] != null) {
          return User.fromJson(decoded);
        }
        return null;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
