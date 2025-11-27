import 'package:bipbip/models/newEvent.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bipbip/models/medication.dart';
import 'package:bipbip/services/event.dart';
import 'package:bipbip/services/medication.dart';
import 'package:bipbip/services/bluetooth_service.dart';
import 'dart:async';
import 'package:bluetooth_classic/models/device.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  final _medicationService = MedicationService();
  final _bluetoothService = BluetoothService();

  String _name = '';
  String? _description;
  DateTime? _takePillDate;
  Medication? _selectedMedication;
  String _selectedFrequency = 'daily';
  int _deviceStatus = Device.disconnected;
  late StreamSubscription<int> _statusSubscription;

  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _statusSubscription = _bluetoothService.statusStream.listen((status) {
      setState(() {
        _deviceStatus = status;
      });
    });
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    try {
      List<Medication> medications = await _medicationService.getMedications();
      setState(() {
        _medications = medications;
      });
    } catch (error) {
      print('Failed to load medications: $error');
    }
  }

  String formatAlarmFromDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$hour,$minute,00";
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _takePillDate != null &&
        _selectedMedication != null) {
      _formKey.currentState!.save();

      NewEvent newEvent = NewEvent(
        userId: 2,
        name: _name,
        description: _description ?? '',
        frequency: _selectedFrequency,
        isActive: true,
        medicationId: _selectedMedication!.id,
        takePillDate: _takePillDate!,
      );

      try {
        await _eventService.createEvent(newEvent);

        if (_deviceStatus == Device.connected) {
          final formatted = formatAlarmFromDateTime(_takePillDate!);
          try {
            await _bluetoothService.write(formatted);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Événement créé et alarme envoyée : $formatted")),
            );
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Erreur Bluetooth lors de l'envoi de l'alarme")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Événement créé (Bluetooth non connecté)")),
          );
        }

        Navigator.pop(context, true);
      } catch (error) {
        print('Erreur lors de la création : $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un événement')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nom de l’événement',
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Nom requis' : null,
                      onSaved: (value) => _name = value!,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description (facultatif)',
                        border: InputBorder.none,
                      ),
                      onSaved: (value) => _description = value,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Fréquence',
                        border: InputBorder.none,
                      ),
                      value: _selectedFrequency,
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
                        DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
                      ],
                      onChanged: (value) => setState(() {
                        _selectedFrequency = value!;
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: Text(
                      _takePillDate == null
                          ? 'Choisir la date et l’heure'
                          : DateFormat('yyyy-MM-dd – HH:mm').format(_takePillDate!),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _takePillDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<Medication>(
                      decoration: const InputDecoration(
                        labelText: 'Médicament',
                        border: InputBorder.none,
                      ),
                      value: _selectedMedication,
                      items: _medications.map((med) {
                        return DropdownMenuItem(
                          value: med,
                          child: Text(med.name),
                        );
                      }).toList(),
                      onChanged: (newValue) => setState(() {
                        _selectedMedication = newValue;
                      }),
                      validator: (value) =>
                          value == null ? 'Veuillez sélectionner un médicament' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Créer l'événement", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
