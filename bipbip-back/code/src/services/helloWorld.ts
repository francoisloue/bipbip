import AbstractService from '../contract/abstract.service';

export class HelloWorld extends AbstractService {
  async executeProcess(): Promise<object> {
    return { message: 'Hello world' };
  }
}

export default new HelloWorld();
