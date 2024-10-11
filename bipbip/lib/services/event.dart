import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bipbip/models/event.dart';

class EventService {
  final String apiUrl = 'http://10.60.113.15:8080/v1/api';

  Future<List<Event>> fetchEvents(int userId) async {
    final response = await http.get(Uri.parse('$apiUrl/event/?author=$userId'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Event> createEvent(Event event) async {
    var jsonEvent = jsonEncode(event.toJson());
    final response = await http.post(
      Uri.parse('$apiUrl/event'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEvent,
    );
    if (response.statusCode == 201) {
      return Event.fromJson(json.decode(response.body));
    } else {
      throw Exception("Aie, erreur lors de la création de l'event");
    }
  }
}
