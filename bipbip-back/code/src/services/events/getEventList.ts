import AbstractService from '../../contract/abstract.service';
import eventAction from '../../actions/eventActions';

export class GetEventList extends AbstractService {
  async executeProcess(): Promise<object> {
    const events = await eventAction.getEventListAction();
    return {
      status: 200,
      events,
    };
  }
}

export default new GetEventList();
