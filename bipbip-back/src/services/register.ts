import { Request, Response } from "express";
import { User } from "../types/user.type";
import RegisterController from "../controller/register";
import { Error, SQLError } from "../db/types/sqlerror.model";

class RegisterService {
    async save(req: Request, res: Response) {
        try {
            const user: User = req.body;
            const savedUser: User = await RegisterController.save(user);
            return res.status(201).json(savedUser);
        } catch (err) {
            const error = err as Error;

            if (error.code === SQLError.DUPLICATED) {
                console.error({ message: 'Identifier already in use' });
                return res.status(409).json({ message: 'Identifier already in use' });
            }

            console.error({ message: 'Error saving User', error: err });
            return res.status(500).json({ message: 'Error saving User', error: err });
        }
    }
}


export default RegisterService;