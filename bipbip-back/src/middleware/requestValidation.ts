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

export function validateNewEventRequest(req: Request, res: Response, next: NextFunction) {
  const requiredFields = ['name', 'author', 'creationDate', 'takePillDate', 'medication'];
  const missingFields = requiredFields.filter(field => !req.body[field]);

  if (missingFields.length === 0) {
    return next();
  } else {
    res.status(400).json({
      message: "Bad Request: some fields are missing",
      missingFields: missingFields,
    });
  }
}

export function validateNewMedicationRequest(req: Request, res: Response, next: NextFunction) {
  const requiredFields = ['name'];
  const missingFields = requiredFields.filter(field => !req.body[field]);

  if (missingFields.length === 0) {
    return next();
  } else {
    res.status(400).json({
      message: "Bad Request: some fields are missing",
      missingFields: missingFields,
    });
  }
}