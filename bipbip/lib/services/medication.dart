import 'dart:convert';
import 'package:bipbip/models/newMedication.dart';
import 'package:http/http.dart' as http;
import 'package:bipbip/models/medication.dart';

class MedicationService {
  final String baseUrl = "http://192.168.1.7:8080/v1/bipbip";

  Future<List<Medication>> getMedications() async {
    final response = await http.get(Uri.parse('$baseUrl/medication'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded['medications'];
      return list.map((m) => Medication.fromJson(m)).toList();
    } else {
      throw Exception("Impossible de récupérer les médicaments ");
    }
  }

  Future<Medication?> getMedicationById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/medication/$id'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return Medication.fromJson(decoded['medications']);
    } else {
      return null;
    }
  }

  Future<Medication> createMedication(NewMedication medication) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medication'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(medication.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return Medication.fromJson(decoded);
    } else {
      throw Exception('Erreur lors de la création du médicament');
    }
  }
}
