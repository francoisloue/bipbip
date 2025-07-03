import AbstractService from '../../contract/abstract.service';
import eventController from '../../actions/eventActions';

export class DeleteEventFromId extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const userId = data.id;
    const actionResponse = await eventController.deleteEventAction(userId);
    return {
        status: 204,
        actionResponse,
    }
  }
}

export default new DeleteEventFromId();
