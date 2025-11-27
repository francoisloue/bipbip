import 'package:bipbip/models/newMedication.dart';

import '../services/medication.dart';
import '../models/medication.dart';

class MedicationController {
  final MedicationService medicationService;

  MedicationController(this.medicationService);

  Future<Medication> createMedication(NewMedication medication) async {
    return await medicationService.createMedication(medication);
  }
}
