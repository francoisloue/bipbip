import { ApiConfig } from '../type/app/apiConfig';
import packageJson from '../../package.json';
import path from 'path';

const apiConfig: ApiConfig = {
  baseUrl: `http://localhost:${process.env.PORT}`,
  version: packageJson.version,
  name: packageJson.name,
  env: 'dev',
  messageBrokerUrl: '',
  iamUrl: '',
  pathToOpenapiConfig: path.resolve(path.join(__dirname, '../openapi.yml')),
  dataBaseUrl: '',
  dataBaseCredentials: {
    user: '',
    password: '',
  },
  keyCloakUrl: '',
};

export default apiConfig;
