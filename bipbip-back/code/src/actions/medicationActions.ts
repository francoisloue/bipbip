import axios from "axios";
import { createMedication, deleteMedication, getMedicationById, getMedications, updateMedication } from "../data/medicationRepository";
import { NewMedication, UpdateMedication } from "../type/data/medications/medicationsTable";
import { ApiMedication } from "../type/action/MedicationSearch";
import apiConfig from "../config/config";

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

    getMedicationFromApi = async (toSearch?: string): Promise<ApiMedication | []> => {
        if (toSearch) {
            const url = `${apiConfig.medicationApiUrl}/medicaments?search=${toSearch}`;
            const response = await axios.get(url);
            return response.data;
        }
        return []
    }
}

export default new MedicationActions();