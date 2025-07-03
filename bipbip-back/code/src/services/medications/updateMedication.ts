import AbstractService from '../../contract/abstract.service';
import medicationsController from '../../actions/medicationActions';
import { UpdateMedication } from '../../type/data/medications/medicationsTable';

export class UpdateMedicationFromId extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const medicationId = data.id;
    const updatedMedication: UpdateMedication = data.body as unknown as UpdateMedication;
    const actionResponse = await medicationsController.updateMedicationAction(medicationId, updatedMedication);
    return {
        status: 200,
        actionResponse,
    }
  }
}

export default new UpdateMedicationFromId();
