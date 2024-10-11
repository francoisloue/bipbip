import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bipbip/models/event.dart';
import 'package:bipbip/models/medication.dart';
import 'package:bipbip/services/event.dart';
import 'package:bipbip/services/medication.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  final _medicationService = MedicationService();
  
  String _name = '';
  String? _description;
  DateTime? _takePillDate;
  Medication? _selectedMedication;

  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
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

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate() && _takePillDate != null && _selectedMedication != null) {
    _formKey.currentState!.save();
    Event newEvent = Event(
      id: 0, // L'ID sera généré côté backend
      name: _name,
      description: _description ?? '',
      author: 2, // Exemple d'ID utilisateur
      creationDate: DateTime.now(),
      takePillDate: _takePillDate!,
      medicationId: 0,
      medication: _selectedMedication,
    );
    try {
      await _eventService.createEvent(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement créé avec succès')),
      );
      Navigator.pop(context, 'success');
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
      appBar: AppBar(title: const Text('Créer un evénement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description (optionnel)'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              ListTile(
                title: Text(_takePillDate == null
                    ? 'Sélectionner la date de prise'
                    : DateFormat('yyyy-MM-dd').format(_takePillDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _takePillDate = pickedDate;
                    });
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
                validator: (value) => value == null ? 'Veuillez sélectionner un médicament' : null,
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
