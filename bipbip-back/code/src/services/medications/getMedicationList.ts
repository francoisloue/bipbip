import AbstractService from '../../contract/abstract.service';
import medicationActions from '../../actions/medicationActions';

export class GetMedicationList extends AbstractService {
  async executeProcess(): Promise<object> {
    const users = await medicationActions.getMedicationListAction();
    return {
      status: 200,
      users,
    };
  }
}

export default new GetMedicationList();
