import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/medication.dart';

class MedicationService {
  final String baseUrl = "http://10.60.113.15:8080/v1/api";

  Future<Medication> fetchObject(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/medication/$id'));
    if (response.statusCode == 200) {
      return Medication.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load object');
    }
  }

  Future<List<Medication>> getMedications() async {
    final response = await http.get(Uri.parse('$baseUrl/medication'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Medication.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medications');
    }
  }

  Future<Medication> createObject(Medication medication) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medication'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(medication.toJson()),
    );
    if (response.statusCode == 201) {
      return Medication.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create medication');
    }
  }

  Future<Medication?> getMedicationById(int medicationId) async {
    final response = await http.get(Uri.parse('$baseUrl/medication/$medicationId'));
    if (response.statusCode == 200) {
      return Medication.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load medication');
    }
  }
}
