export type ApiConfig = {
  baseUrl: string;
  version: string;
  name: string;
  env: string;
  messageBrokerUrl: string;
  iamUrl: string;
  pathToOpenapiConfig: string;
  dataBaseUrl: string;
  dataBaseCredentials: DataBaseCredentials;
  keyCloakUrl: string;
};

type DataBaseCredentials = {
  user: string;
  password: string;
};
