import AbstractService from '../../contract/abstract.service';
import EventsController from '../../actions/eventActions';

export class GetEventById extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const eventId: number = data?.id;
    const event = await EventsController.getEventByIdAction(eventId);
    return {
      status: 200,
      event,
    };
  }
}

export default new GetEventById();
