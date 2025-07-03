import AbstractService from '../../contract/abstract.service';
import usersController from '../../actions/usersActions';

export class DeleteUserFromId extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const userId = data.id;
    const actionResponse = await usersController.deleteUserAction(userId);
    return {
        status: 204,
        actionResponse,
    }
  }
}

export default new DeleteUserFromId();
