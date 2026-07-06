import 'dart:async';
import 'package:bipbip/models/newEvent.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bipbip/models/medication.dart';
import 'package:bipbip/services/event.dart';
import 'package:bipbip/services/medication.dart';
import 'package:bipbip/controllers/ble_sync_controller.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  final _medicationService = MedicationService();
  final _bleService = BleService();

  String _name = '';
  String? _description;
  DateTime? _takePillDate;
  Medication? _selectedMedication;
  String _selectedFrequency = 'daily';

  // Timer pour le debouncing
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _takePillDate != null &&
        _selectedMedication != null) {
      _formKey.currentState!.save();

      NewEvent newEvent = NewEvent(
        userId: 2, // Hardcoded for MVP
        name: _name,
        description: _description ?? '',
        frequency: _selectedFrequency,
        isActive: true,
        medicationId: _selectedMedication!.id,
        takePillDate: _takePillDate!,
      );

      try {
        await _eventService.createEvent(newEvent);
        
        // Envoi automatique à l'ESP32 si connecté
        final connectedDevice = _bleService.getConnectedDevice();
        if (connectedDevice != null) {
          final hour = newEvent.takePillDate?.hour.toString().padLeft(2, '0');
          final minute = newEvent.takePillDate?.minute.toString().padLeft(2, '0');
          final second = newEvent.takePillDate?.second.toString().padLeft(2, '0');
          
          try {
            await _bleService.write("$hour,$minute,$second");
          } catch (e) {
            print("Erreur envoi BLE auto : $e");
          }
        }

        if (!context.mounted) return;
        Navigator.pop(context, true);
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création : $error')),
        );
      }
    } else if (_takePillDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une date et une heure')),
      );
    } else if (_selectedMedication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un médicament')),
      );
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
                _buildCard(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nom de l’événement',
                      border: InputBorder.none,
                      icon: Icon(Icons.event),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nom requis' : null,
                    onSaved: (value) => _name = value!,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description (facultatif)',
                      border: InputBorder.none,
                      icon: Icon(Icons.description),
                    ),
                    onSaved: (value) => _description = value,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Fréquence',
                      border: InputBorder.none,
                      icon: Icon(Icons.repeat),
                    ),
                    value: _selectedFrequency,
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
                      DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
                    ],
                    onChanged: (value) => setState(() => _selectedFrequency = value!),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      _takePillDate == null
                          ? 'Choisir la date et l’heure'
                          : DateFormat('yyyy-MM-dd – HH:mm').format(_takePillDate!),
                    ),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
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
                              date.year, date.month, date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  child: Autocomplete<Medication>(
                    displayStringForOption: (Medication m) => m.name,
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Medication>.empty();
                      }
                      final completer = Completer<Iterable<Medication>>();
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 600), () async {
                        try {
                          final results = await _medicationService.searchMedications(textEditingValue.text);
                          completer.complete(results);
                        } catch (e) {
                          completer.complete(const Iterable<Medication>.empty());
                        }
                      });

                      return completer.future;
                    },
                    onSelected: (Medication selection) {
                      setState(() => _selectedMedication = selection);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Rechercher un médicament',
                          border: InputBorder.none,
                          icon: Icon(Icons.medical_services),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedMedication != null) ...[
                  const SizedBox(height: 8),
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selectedMedication!.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                if (_selectedMedication!.dosageSummary.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(_selectedMedication!.dosageSummary, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                  ),
                                Text(_selectedMedication!.formePharmaceutique, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Créer l'événement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: child,
      ),
    );
  }
}
