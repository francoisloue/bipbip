import '../services/medication.dart';
import '../models/medication.dart';

class MedicationController {
  final MedicationService medicationService;

  MedicationController(this.medicationService);

  Future<Medication> createMedication(Medication medication) async {
    return await medicationService.createObject(medication);
  }
}
