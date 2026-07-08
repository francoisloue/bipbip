import 'package:bipbip/models/newMedication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/medication_controller.dart';
import '../services/medication.dart';

class CreateMedicationView extends StatefulWidget {
  const CreateMedicationView({super.key});

  @override
  _CreateMedicationViewState createState() => _CreateMedicationViewState();
}

class _CreateMedicationViewState extends State<CreateMedicationView> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = MedicationController(MedicationService());
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _noticeUrlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newMedication = NewMedication(
        name: _nameController.text,
        imageUrl: _imageUrlController.text,
        noticeUrl: _noticeUrlController.text,
      );

      try {
        await _medicationController.createMedication(newMedication);
        HapticFeedback.lightImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Médicament créé avec succès'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Créer un médicament'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ajoute un médicament manuellement s'il n'est pas trouvé dans la recherche automatique.",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du médicament',
                  hintText: 'ex: Doliprane 500mg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Nom requis' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noticeUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la notice',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createMedication,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isLoading ? 'Création...' : 'Créer le médicament',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
