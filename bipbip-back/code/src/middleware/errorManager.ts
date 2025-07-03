import { Response, NextFunction, ErrorRequestHandler, Request } from 'express';

export const openApiErrorHandler: ErrorRequestHandler = (
  err: any,
  _req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (err && err.errors) {
    const clientResponse = {
      status: err.status || 400,
      message: 'Erreur de validation de la requête.',
      details: err.errors.map((e: any) => ({
        field: e.path,
        issue: e.message,
      })),
    };
    res.status(err.status || 400).json(clientResponse);
  } else {
    return next(err);
  }
};