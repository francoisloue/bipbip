import 'package:bipbip/config/app_config.dart';
import 'package:bipbip/views/list_event.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _config = AppConfig();

  @override
  void initState() {
    super.initState();
    _config.addListener(_onConfigChanged);
  }

  @override
  void dispose() {
    _config.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BipBip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.bluetooth),
            tooltip: 'Bluetooth',
            onPressed: () => Navigator.pushNamed(context, '/bluetooth'),
          ),
        ],
      ),
      body: EventListView(key: ValueKey(_config.userId), userId: _config.userId),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create-event');
          if (result == true) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Événement créé'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
