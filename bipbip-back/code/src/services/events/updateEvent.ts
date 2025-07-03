import AbstractService from '../../contract/abstract.service';
import eventsController from '../../actions/eventActions';
import { UpdateEvent } from '../../type/data/events/eventsTable';

export class UpdateEventFromId extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const eventId = data.id;
    const updatedEvent: UpdateEvent = data.body as unknown as UpdateEvent;
    const actionResponse = await eventsController.updateEventAction(eventId, updatedEvent);
    return {
        status: 200,
        actionResponse,
    }
  }
}

export default new UpdateEventFromId();
