import AbstractService from '../../contract/abstract.service';
import eventController from '../../actions/eventActions';
import { NewEvent } from '../../type/data/events/eventsTable';

export class CreateEvent extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const newEvent: NewEvent = data.body as unknown as NewEvent;
    const actionResponse = await eventController.createEventAction(newEvent);
    return {
        status: 201,
        actionResponse,
    }
  }
}

export default new CreateEvent();
