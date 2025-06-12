export type ApiConfig = {
  dataBasePort: number;
  dataBaseHost: string;
  dataBaseName: string;
  baseUrl: string;
  version: string;
  name: string;
  env: string;
  pathToOpenapiConfig: string;
  dataBaseCredentials: DataBaseCredentials;
};

type DataBaseCredentials = {
  user: string;
  password: string;
};
