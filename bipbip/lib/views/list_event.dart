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
  final EventController eventController =
      EventController(EventService(), MedicationService());

  @override
  void initState() {
    super.initState();
    futureEvents = eventController.getUserEvents(2);
  }

  Future<void> _reloadEvents() async {
    futureEvents = eventController.getUserEvents(2);
    await futureEvents;
    setState(() {});
  }

  Future<bool?> _confirmDelete(Event event) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l’événement ?'),
        content: Text('« ${event.name} » sera définitivement supprimé.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer')),
        ],
      ),
    );
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

            final events = snapshot.data!;
            final activeEvents = events.where((e) => e.isActive).toList();
            activeEvents.sort((a, b) => a.takePillDate!.compareTo(b.takePillDate!));

            final now = DateTime.now();
            final upcoming = activeEvents
                .where((e) =>
                    e.takePillDate != null && e.takePillDate!.isAfter(now))
                .toList()
              ..sort((a, b) => a.takePillDate!.compareTo(b.takePillDate!));
            final nextEvent = upcoming.isNotEmpty ? upcoming.first : null;

            // Exclure la prochaine prise des autres listes
            final remainingEvents =
                List<Event>.from(activeEvents)..remove(nextEvent);

            final dailyEvents =
                remainingEvents.where((e) => e.frequency == 'daily').toList();
            final weeklyEvents =
                remainingEvents.where((e) => e.frequency == 'weekly').toList();

            return ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (nextEvent != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      "Prochaine prise de médicament",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.blueAccent),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildEventCard(nextEvent, isEmbedded: true),
                      ),
                    ),
                  ),
                ],
                if (dailyEvents.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Prises quotidiennes",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...dailyEvents.map((e) => _buildEventCard(e)),
                ],
                if (weeklyEvents.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Prises hebdomadaires",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...weeklyEvents.map((e) => _buildEventCard(e)),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          );
          if (result == true) _reloadEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(Event event, {bool isEmbedded = false}) {
    final timeStr = event.takePillDate != null
        ? DateFormat.Hm().format(event.takePillDate!)
        : '--:--';
    final dateStr = event.takePillDate != null
        ? DateFormat.yMMMMd().format(event.takePillDate!)
        : '';
    final imageUrl = event.medication?.imageUrl;
    final medName = event.medication?.name ?? '';

    final cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(timeStr,
                  style: const TextStyle(
                      fontSize: 42, fontWeight: FontWeight.bold)),
              if (dateStr.isNotEmpty)
                Text(dateStr,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(event.name,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              if (medName.isNotEmpty)
                Text('Médicament : $medName',
                    style: const TextStyle(fontSize: 14)),
              if (event.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(event.description,
                      style: const TextStyle(fontSize: 13)),
                ),
            ],
          ),
        ),
        if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(left: 12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.medication,
                size: 32,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );

    if (isEmbedded) return cardContent;

    return Dismissible(
      key: Key('event-${event.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await _confirmDelete(event);
        if (confirmed == true) {
          await eventController.deleteEvent(event.id!);
          await _reloadEvents();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Événement supprimé')),
          );
        }
        return confirmed ?? false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: cardContent,
        ),
      ),
    );
  }
}
