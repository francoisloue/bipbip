import { Request, Response, NextFunction } from "express";

export function validateUserCreation(req: Request, res: Response, next: NextFunction) {
  if (req.body.name && req.body.password) {
    return next();
  } else {
    res.status(400).json({
    message: "Bad Request: 'name' and 'password' are required",
  });
  }
}

export function validateUserAuthRequest(req: Request, res: Response, next: NextFunction) {
    if (req.body.name && req.body.password) {
        return next();
    } else {
        res.status(400).json({
            message: "Bad Request: 'name' and 'password' are required",
        });
    }
}
