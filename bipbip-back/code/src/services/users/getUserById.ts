import AbstractService from '../../contract/abstract.service';
import usersController from '../../actions/usersActions';

export class GetUserById extends AbstractService {
  async executeProcess(data: any): Promise<object> {
    const userId: number = data?.id;
    const user = await usersController.getUserByIdAction(userId);
    return {
      status: 200,
      user,
    };
  }
}

export default new GetUserById();
