import AbstractService from '../../contract/abstract.service';
import eventAction from '../../actions/eventActions';

export class GetEventList extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const userId: number = data?.user;
    const events = await eventAction.getEventByUserId(userId);
    return {
      status: 200,
      events,
    };
  }
}

export default new GetEventList();
