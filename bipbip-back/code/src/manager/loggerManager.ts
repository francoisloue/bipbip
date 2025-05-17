import { NextFunction, Request, Response } from 'express';
import path from 'path';
import { createLogger, format, Logger, transports } from 'winston';

export const logger: Logger = createLogger({
  transports: [
    new transports.Console(),
    new transports.File({
      level: 'warn',
      filename: path.resolve(path.join(__dirname, '../../logs/logsError.log')),
    }),
  ],
  format: format.combine(
    format.colorize(),
    format.json(),
    format.timestamp({
      format: 'YYYY-MM-DD HH:mm:ss',
    }),
    format.printf(({ level, message, timestamp }) => {
      return `${timestamp} [${level}]: ${message}`;
    }),
  ),
});

export function setLogger(logger: Logger) {
  return (_req: Request, res: Response, next: NextFunction) => {
    res.locals.logger = logger;
    next();
  };
}
