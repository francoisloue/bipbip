import express from 'express';
import { ApiConfig } from '../type/app/apiConfig';
import { logger, setLogger } from '../manager/loggerManager';
import cors from 'cors';
import { initialize } from 'express-openapi';
import config from '../manager/configManager';
import Router from '../infrastructure/router';
import { serviceRegister } from '../serviceRegister';
import expressWinston from 'express-winston';
import { Service } from '../type/app/serviceType';

const defaultMiddlewares = [
  express.json({
    type: 'application/json',
  }),
];

export const initApi = (options: {
  apiConfig: ApiConfig;
  serviceRegister: Service[];
  expressOpenApiSettings?: object;
  middlewares?: express.Handler[];
}) => {
  const app: express.Application = express();

  const apiLogger: express.Handler = expressWinston.logger({
    winstonInstance: logger,
    meta: true,
    expressFormat: false,
    colorize: true,
    statusLevels: true,
    msg: (req, res) =>
      JSON.stringify(
        {
          timestamp: new Date().toISOString(),
          level: res.statusCode >= 400 ? 'warn' : 'info',
          message: `HTTP ${req.method} ${req.url}`,
          meta: {
            req: {
              method: req.method,
              url: req.originalUrl,
              headers: req.headers,
            },
            res: {
              statusCode: res.statusCode,
            },
          },
        },
        null,
        2,
      ),
  });

  app.use(
    ...(options.middlewares ?? defaultMiddlewares),
    cors(),
    apiLogger,
    setLogger(logger),
  );

  logger.info('Service initialization');

  serviceRegister.forEach((service) => {
    Router.addOperation(service.operationId, Router.defaultHandler);
  });

  initialize({
    app,
    apiDoc: config.pathToOpenapiConfig,
    operations: Router.operations,
    ...options.expressOpenApiSettings,
  });

  const PORT = process.env.PORT || 8080;

  app.listen(PORT, () => {
    logger.info(`Listening on port ${PORT}`);
  });
};
