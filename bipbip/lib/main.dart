import 'package:bipbip/views/list_event.dart';
import 'package:bipbip/views/medication.dart';
import 'package:flutter/material.dart';
import 'package:bipbip/views/create_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication & Events App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EventListScreen(), // La vue principale est la liste des événements
      routes: {
        '/create-medication': (context) => const CreateMedicationView(), // Route pour ajouter un médicament
        '/create-event': (context) => const CreateEventScreen(), // Route pour ajouter un événement
      },
    );
  }
}

// Écran principal : Liste des événements
class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Mes événements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () {
              // Naviguer vers la vue pour créer un nouveau médicament
              Navigator.pushNamed(context, '/create-medication');
            },
          ),
        ],
      ),
      body: const EventListView(userId: 2), // Remplacez l'ID de l'utilisateur si nécessaire
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Naviguer vers la vue pour créer un nouvel événement
          final result = await Navigator.pushNamed(context, '/create-event');
          if (result == 'success') {
            // Rafraîchir la liste après la création d'un événement
            setState(() {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Événement ajouté avec succès')),
              );
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
