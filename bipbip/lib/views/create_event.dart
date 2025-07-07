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
  String _selectedFrequency = 'daily'; // 👈 Nouvelle variable
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
    if (_formKey.currentState!.validate() && _takePillDate != null && _selectedMedication != null) {
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
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Événement créé, mais erreur Bluetooth")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Événement créé (appareil non connecté)")),
          );
        }

        Navigator.pop(context, true);
      } catch (error) {
        print('Erreur lors de la création de l\'événement: $error');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez entrer un nom' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description (optionnel)'),
                onSaved: (value) => _description = value,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Fréquence'),
                value: _selectedFrequency,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
                  DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
              ),
              ListTile(
                title: Text(_takePillDate == null
                    ? 'Sélectionner la date et l\'heure de prise'
                    : DateFormat('yyyy-MM-dd HH:mm').format(_takePillDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _takePillDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              DropdownButtonFormField<Medication>(
                decoration: const InputDecoration(labelText: 'Médicament'),
                value: _selectedMedication,
                items: _medications.map((Medication medication) {
                  return DropdownMenuItem<Medication>(
                    value: medication,
                    child: Text(medication.name),
                  );
                }).toList(),
                onChanged: (Medication? newValue) {
                  setState(() {
                    _selectedMedication = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un médicament' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Créer l\'événement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}