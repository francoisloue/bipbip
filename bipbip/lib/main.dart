import 'package:bipbip/config/app_config.dart';
import 'package:bipbip/views/home_screen.dart';
import 'package:bipbip/views/create_event.dart';
import 'package:bipbip/views/bluetooth_page.dart';
import 'package:bipbip/views/profile_page.dart';
import 'package:bipbip/views/medication.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    return MaterialApp(
      title: 'BipBip',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _config.themeMode,
      home: const HomeScreen(),
      routes: {
        '/create-event': (context) => const CreateEventScreen(),
        '/bluetooth': (context) => const BluetoothPage(),
        '/profile': (context) => const ProfilePage(),
        '/create-medication': (context) => const CreateMedicationView(),
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
      ),
      scaffoldBackgroundColor: Colors.grey.shade900,
    );
  }
}
