import 'dart:convert';
import 'package:bipbip/models/newEvent.dart';
import 'package:http/http.dart' as http;
import 'package:bipbip/models/event.dart';

class EventService {
  final String baseUrl = "http://192.168.1.7:8080/v1/bipbip";

  Future<List<Event>> fetchUserEvents(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/event?user=2'));

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        final List<dynamic> list = decoded['events'];
        return list.map((e) => Event.fromJson(e)).toList();
      } catch (e) {
        print('Erreur de parsing Event : $e');
        throw Exception('Erreur parsing event: $e');
      }
    } else {
      throw Exception('Erreur lors du chargement des événements');
    }
  }

  Future<Event> createEvent(NewEvent event) async {
    final response = await http.post(
      Uri.parse('$baseUrl/event'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return Event.fromJson(decoded);
    } else {
      throw Exception('Erreur lors de la création de l’événement');
    }
  }

  Future<void> deleteEvent(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/event/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de l’événement');
    }
  }
}
