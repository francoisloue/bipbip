import AbstractService from '../../contract/abstract.service';
import medicationController from '../../actions/medicationActions';
import { NewMedication } from '../../type/data/medications/medicationsTable';

export class CreateMedication extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const newMedication: NewMedication = data.body as unknown as NewMedication;
    const actionResponse = await medicationController.createMedicationAction(newMedication);
    return {
        status: 201,
        actionResponse,
    }
  }
}

export default new CreateMedication();
