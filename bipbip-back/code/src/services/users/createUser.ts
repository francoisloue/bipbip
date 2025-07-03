import AbstractService from '../../contract/abstract.service';
import usersController from '../../actions/usersActions';
import { NewUser } from '../../type/data/users/usersTable';

export class CreateUser extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const newUser: NewUser = data.body as unknown as NewUser;
    const actionResponse = await usersController.createUserAction(newUser);
    return {
        status: 201,
        actionResponse,
    }
  }
}

export default new CreateUser();
