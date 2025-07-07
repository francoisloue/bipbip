import 'package:bipbip/models/event.dart';
import 'package:bipbip/models/medication.dart';
import 'package:bipbip/models/newEvent.dart';
import 'package:bipbip/services/event.dart';
import 'package:bipbip/services/medication.dart';

class EventController {
  final EventService eventService;
  final MedicationService medicationService;

  EventController(this.eventService, this.medicationService);

  Future<List<Event>> getUserEvents(int userId) async {
    List<Event> events = await eventService.fetchUserEvents(userId);
    for (var event in events) {
      try {
        Medication? medication = await medicationService.getMedicationById(event.medicationId);
        event.medication = medication;
      } catch (_) {
        event.medication = null;
      }
    }
    return events;
  }

  Future<void> addEvent(NewEvent event) async {
    await eventService.createEvent(event);
  }
}
