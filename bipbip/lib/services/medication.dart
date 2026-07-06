import 'dart:convert';
import 'package:bipbip/models/newMedication.dart';
import 'package:http/http.dart' as http;
import 'package:bipbip/models/medication.dart';

class MedicationService {
  final String baseUrl = "http://10.60.116.151:8080/v1/bipbip";

  Future<List<Medication>> getMedications() async {
    final response = await http.get(Uri.parse('$baseUrl/medication'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded['medications'] ?? [];
      return list.map((m) => Medication.fromJson(m)).toList();
    } else {
      throw Exception("Impossible de récupérer les médicaments ");
    }
  }

  Future<Medication?> getMedicationById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/medication/$id'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['medications'] != null) {
        return Medication.fromJson(decoded['medications']);
      }
      return null;
    } else {
      return null;
    }
  }

  Future<Medication> createMedication(NewMedication medication) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medication'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(medication.toJson()),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return Medication.fromJson(decoded);
    } else {
      throw Exception('Erreur lors de la création du médicament');
    }
  }

  Future<List<Medication>> searchMedications(String medicationName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medication?name=$medicationName'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded['medications'] ?? [];
      return list.map((m) => Medication.fromJson(m)).toList();
    } else {
      throw Exception('Erreur lors de la recherche des médicaments');
    }
  }
}
