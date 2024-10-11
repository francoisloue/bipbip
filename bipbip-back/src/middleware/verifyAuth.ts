import { Request, Response, NextFunction } from "express";
import jwt, { Secret } from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

export function authenticateJWT(req: Request, res: Response, next: NextFunction) {
    const token = req.headers["authorization"];
    if (!token) {
        res.status(403).json({
            message: "Permission denied",
            error: "No token"
        });
    } else {
        const JWT_SECRET = process.env.JWT_SECRET
        jwt.verify(token, JWT_SECRET as Secret, (err, user) => {
            if (err) {
                res.status(403).json({
                    message: "Permission denied",
                    error: err
                });
            }
            return next();
        });
    }
}
