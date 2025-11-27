import 'package:bipbip/models/newMedication.dart';
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

  final MedicationController _medicationController =
      MedicationController(MedicationService());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _noticeUrlController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _createMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final newMedication = NewMedication(
        name: _nameController.text,
        imageUrl: _imageUrlController.text,
        noticeUrl: _noticeUrlController.text,
      );

      try {
        final createdMedication =
            await _medicationController.createMedication(newMedication);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication created: ${createdMedication.name}')),
        );
        _nameController.clear();
        _imageUrlController.clear();
        _noticeUrlController.clear();
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
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _noticeUrlController.dispose();
    super.dispose();
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
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noticeUrlController,
                decoration: const InputDecoration(
                  labelText: 'Notice URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the notice URL';
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
}
