import { ApiConfig } from '../type/app/apiConfig';
import apiConfig from '../config/config';

export class ConfigManager {
  private static config: ApiConfig;

  static getConfig(): ApiConfig {
    ConfigManager.config = apiConfig;
    return ConfigManager.config;
  }
}

export default ConfigManager.getConfig();
