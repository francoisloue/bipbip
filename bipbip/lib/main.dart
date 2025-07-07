import 'package:bipbip/views/list_event.dart';
import 'package:bipbip/views/medication.dart';
import 'package:bipbip/views/create_event.dart';
import 'package:bipbip/views/bluetooth_page.dart'; // ✅ Import de la page Bluetooth
import 'package:flutter/material.dart';

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
      home: const EventListScreen(),
      routes: {
        '/create-medication': (context) => const CreateMedicationView(),
        '/create-event': (context) => const CreateEventScreen(),
        '/bluetooth': (context) => const BluetoothPage(), // ✅ Route Bluetooth
      },
    );
  }
}

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
              Navigator.pushNamed(context, '/create-medication');
            },
          ),
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              Navigator.pushNamed(context, '/bluetooth'); // ✅ Accès à la page Bluetooth
            },
          ),
        ],
      ),
      body: const EventListView(userId: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create-event');
          if (result == 'success') {
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
