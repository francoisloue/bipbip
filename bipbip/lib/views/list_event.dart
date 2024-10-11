import 'package:bipbip/services/medication.dart';
import 'package:bipbip/views/create_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bipbip/models/event.dart';
import 'package:bipbip/controllers/event_controller.dart';
import 'package:bipbip/services/event.dart';

class EventListView extends StatefulWidget {
  const EventListView({super.key, required int userId});

  @override
  _EventListViewState createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  late Future<List<Event>> futureEvents;
  final EventController eventController = EventController(EventService(), MedicationService());

  @override
  void initState() {
    super.initState();
    futureEvents = eventController.getUserEvents(2);
  }

  Future<void> _reloadEvents() async {
    // Pas besoin d'utiliser setState ici, juste attendre la récupération des événements
    futureEvents = eventController.getUserEvents(2);
    await futureEvents;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _reloadEvents,
        child: FutureBuilder<List<Event>>(
          future: futureEvents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error list: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No events found.'));
            }

            List<Event> events = snapshot.data!;

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                String formattedDate = event.takePillDate != null
                    ? DateFormat('yyyy-MM-dd').format(event.takePillDate!)
                    : 'Date non spécifiée';
                String medicationName = event.medication?.name ?? 'Aucun médicament';
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Médicament : $medicationName'),
                        Text('Date de prise : $formattedDate'),
                        if (event.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Description : ${event.description}'),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Naviguer vers la vue pour créer un nouvel événement
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
          // Si un événement a été créé (result == true), recharger la liste des événements
          if (result == true) {
            setState(() {
              // Met à jour les événements uniquement si un nouvel événement a été ajouté
              futureEvents = eventController.getUserEvents(2);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
