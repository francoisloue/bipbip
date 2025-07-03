import { initApi } from './manager/initializeManager';
import { serviceRegister } from './serviceRegister';

import apiConfig from './config/config';

initApi({
  apiConfig,
  serviceRegister,
  middlewares: [],
});
