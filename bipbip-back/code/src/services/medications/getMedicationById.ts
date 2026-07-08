import AbstractService from '../../contract/abstract.service';
import medicationActions from '../../actions/medicationActions';

export class GetMedicationById extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const medicationId: number = data?.id;
    const medications = await medicationActions.getMedicationByIdAction(medicationId);
    return {
      status: 200,
      medications,
    };
  }
}

export default new GetMedicationById();
