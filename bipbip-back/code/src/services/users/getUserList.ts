import AbstractService from '../../contract/abstract.service';
import usersController from '../../actions/usersActions';

export class GetUserList extends AbstractService {
  async executeProcess(): Promise<object> {
    const users = await usersController.getUserListAction();
    return {
      status: 200,
      users,
    };
  }
}

export default new GetUserList();
