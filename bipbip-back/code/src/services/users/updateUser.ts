import AbstractService from '../../contract/abstract.service';
import usersController from '../../actions/usersActions';
import { UpdateUser } from '../../type/data/users/usersTable';

export class UpdateUserFromId extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const userId = data.id;
    const updatedUser: UpdateUser = data.body as unknown as UpdateUser;
    const actionResponse = await usersController.updateUserAction(userId, updatedUser);
    return {
        status: 200,
        actionResponse,
    }
  }
}

export default new UpdateUserFromId();
