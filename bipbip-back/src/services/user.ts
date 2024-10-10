import { Request, Response } from "express";
import { User } from "../types/user.type";
import UserController from "../controller/user";
import { Error, SQLError } from "../db/types/sqlerror.model";

class UserService {
    async save(req: Request, res: Response) {
        try {
            const user: User = req.body;
            const savedUser: User = await UserController.save(user);
            return res.status(200).json(savedUser);
        } catch (err) {
            const error = err as Error;
            switch(error.code) {
                case SQLError.DUPLICATED:
                    console.error({ message: 'Identifier already in use'});
                    return res.status(500).json({ message: 'Identifier already in use'});
            }
            console.error({ message: 'Error saving transaction', error: err});
            return res.status(500).json({ message: 'Error saving transaction', error: err});
        }
    }
    
    async retrieveAll(req: Request, res: Response) {
        try {
            const allUser: User[] = await UserController.retrieveAll();
            return res.status(200).json(allUser)
        } catch (err) {
            console.log('Error retrieving all the users:', err);
            return res.status(500).json({message: 'Error retrieving all the users'})
        }
    }
    async retrieveById(req: Request, res: Response) {
        try {
            let id: string | number | undefined = req.params.id;
            const allUser: User = await UserController.retrieveById(id);
            return res.status(200).json(allUser)
        } catch (err) {
            console.log('Error retrieving all the users:', err);
            return res.status(500).json({message: 'Error retrieving all the users'})
        }
    }
    async delete(req: Request, res: Response) {
        try {
            let id: string | number | undefined = req.params.id
            const affectedTransaction: number = await UserController.delete(id)
            return res.status(200).json({
                message: `Transaction with id '${affectedTransaction}' deleted`,
                links: {
                    api: `http://${process.env.HOST}:${process.env.PORT}/api/${process.env.ENV}/`,
                    healthcheck: `http://${process.env.HOST}:${process.env.PORT}/api/${process.env.ENV}/healthcheck`,
                    users: `http://${process.env.HOST}:${process.env.PORT}/api/${process.env.ENV}/users`
                }
        })
        } catch (err) {
            console.log('Error retrieving all the transactions:', err);
            return res.status(500).json({message: 'Error retrieving all the transactions'})
        }
    }
}

export default UserService;