import AbstractService from '../../contract/abstract.service';
import medicationActions from '../../actions/medicationActions';

export class SearchMedication extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const medications = await medicationActions.getMedicationFromApi(data?.name);
    const response = {
      status: 200,
      medications,
    };
    return response;
  }
}

export default new SearchMedication();
