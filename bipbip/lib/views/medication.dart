import 'package:flutter/material.dart';
import '../controllers/medication_controller.dart';
import '../models/medication.dart';
import '../services/medication.dart';

class CreateMedicationView extends StatefulWidget {
  const CreateMedicationView({super.key});

  @override
  _CreateMedicationViewState createState() => _CreateMedicationViewState();
}

class _CreateMedicationViewState extends State<CreateMedicationView> {
  final _formKey = GlobalKey<FormState>();

  // Instancier le contrôleur
  final MedicationController _medicationController = MedicationController(MedicationService());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Fonction pour envoyer le médicament en passant par le contrôleur
  Future<void> _createMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final medication = Medication(
        id: 0,
        name: _nameController.text,
        description: _descriptionController.text,
      );

      try {
        // Utiliser le contrôleur pour créer le médicament
        final createdMedication = await _medicationController.createMedication(medication);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication created: ${createdMedication.name}')),
        );
        // Réinitialiser les champs du formulaire
        _nameController.clear();
        _descriptionController.clear();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to create medication: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the medication';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton(
                onPressed: _isLoading ? null : _createMedication,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
