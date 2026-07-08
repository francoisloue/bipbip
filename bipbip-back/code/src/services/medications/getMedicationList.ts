import AbstractService from '../../contract/abstract.service';
import medicationActions from '../../actions/medicationActions';

export class GetMedicationList extends AbstractService {
  async executeProcess(): Promise<object> {
    const medications = await medicationActions.getMedicationListAction();
    return {
      status: 200,
      medications,
    };
  }
}

export default new GetMedicationList();
