import { NextFunction, Request, Response } from 'express';

export type Operations = {
  [operationId: string]: (...args: any[]) => any;
};

export type RouteHandler = (
  req: Request,
  res: Response,
  next: NextFunction,
) => Response | void | Promise<Response | void>;

export type DefaultOperation = {
  operation: string;
  handler: RouteHandler;
};

export type Redirect = {
  url: string;
};
