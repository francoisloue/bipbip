import 'package:bipbip/models/event.dart';
import 'package:bipbip/models/medication.dart';
import 'package:bipbip/services/event.dart';
import 'package:bipbip/services/medication.dart';

class EventController {
  final EventService eventService;
  final MedicationService medicationService;

  EventController(this.eventService, this.medicationService);

  Future<List<Event>> getUserEvents(int userId) async {
    List<Event> events = await eventService.fetchEvents(userId);
    for (var event in events) {
      Medication? medication = await medicationService.getMedicationById(event.medicationId);
      event.medication = medication;
    }
    return events;
  }

  Future<Event> addEvent(Event event) async {
    return await eventService.createEvent(event);
  }
}
