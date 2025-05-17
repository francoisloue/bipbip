import { NextFunction, Response } from 'express';
import { DefaultOperation, Operations, RouteHandler } from '../type/app/router';
import { Controller } from './controller';
import { ApiRequest } from '../type/app/apiRequest';

export class Router {
  static router: Router;

  private _controller: Controller;

  public operations: Operations = {};

  constructor() {
    this._controller = new Controller();
    this.addDefaultOperations();
  }

  static getInstance() {
    if (!Router.router) {
      Router.router = new Router();
    }
    return Router.router;
  }

  public defaultHandler = async (
    req: ApiRequest,
    res: Response,
    next: NextFunction,
  ): Promise<Response | void> => {
    try {
      return await this._controller.render(req, res);
    } catch (e) {
      return next(e);
    }
  };

  public healthCheckHandler = (
    req: ApiRequest,
    res: Response,
    next: NextFunction,
  ): Response | void => {
    try {
      return this._controller.healthcheck(req, res);
    } catch (e) {
      return next(e);
    }
  };

  public versionHandler = (
    req: ApiRequest,
    res: Response,
    next: NextFunction,
  ): Response | void => {
    try {
      return this._controller.version(req, res);
    } catch (e) {
      return next(e);
    }
  };

  public addOperation = (operation: string, handler: RouteHandler): void => {
    this.operations[operation] = handler ?? this.defaultHandler;
  };

  private addDefaultOperations(): void {
    this.getDefaultOperations().forEach(({ operation, handler }) => {
      this.addOperation(operation, handler);
    });
  }

  private getDefaultOperations = (): DefaultOperation[] => [
    {
      operation: 'healthcheck',
      handler: this.healthCheckHandler,
    },
    {
      operation: 'version',
      handler: this.versionHandler,
    },
  ];
}

export default Router.getInstance();
