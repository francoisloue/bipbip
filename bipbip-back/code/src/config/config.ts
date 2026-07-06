import { ApiConfig } from '../type/app/apiConfig';
import packageJson from '../../package.json';
import path from 'path';

const apiConfig: ApiConfig = {
  baseUrl: `http://localhost:${process.env.PORT}`,
  version: packageJson.version,
  name: packageJson.name,
  env: 'dev',
  pathToOpenapiConfig: path.resolve(path.join(__dirname, '../openapi.yml')),
  dataBaseName: 'bipbip',
  dataBaseHost: 'localhost',
  dataBasePort: 5432,
  dataBaseCredentials: {
    user: 'bipuser',
    password: 'bipsecret',
  },
  medicationApiUrl: "https://medicaments-api.giygas.dev/v1"
};

export default apiConfig;
