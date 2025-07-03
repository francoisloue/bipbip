import { createMedication, deleteMedication, getMedicationById, getMedications, updateMedication } from "../data/medicationRepository";
import { NewMedication, UpdateMedication } from "../type/data/medications/medicationsTable";

class MedicationActions {
    async getMedicationListAction() {
        return await getMedications();
    }

    async createMedicationAction(data: NewMedication) {
        return await createMedication(data);
    }

    async getMedicationByIdAction(id: number) {
        return await getMedicationById(id);
    }
    
    async updateMedicationAction(id: number, updatedMedication: UpdateMedication) {
        return await updateMedication(id, updatedMedication);
    }

    async deleteMedicationAction(id: number) {
        return await deleteMedication(id);
    }
}

export default new MedicationActions();