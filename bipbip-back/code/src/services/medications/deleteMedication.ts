import AbstractService from '../../contract/abstract.service';
import medicationActions from '../../actions/medicationActions';

export class DeleteMedicationFromId extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const medicationId = data.id;
    const actionResponse = await medicationActions.deleteMedicationAction(medicationId);
    return {
        status: 204,
        actionResponse,
    }
  }
}

export default new DeleteMedicationFromId();
