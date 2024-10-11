import jwt, { Secret } from "jsonwebtoken";
import bcrypt from "bcrypt";
import { Request, Response } from "express";
import { User } from "../types/user.type";
import dotenv from "dotenv";
import AuthenticateController from "../controller/authenticate";

class AuthenticateService {
    constructor() {
        dotenv.config();
    }

    async login(req: Request, res: Response) {
        const { name, password } = req.body;
        const user: User | null = await AuthenticateController.retrieveByName(name);
        if (!user || !(await bcrypt.compare(password, user.password as string))) {
            return res.status(401).json({ message: "Invalid credentials" });
        }
        const token = jwt.sign({ id: user.id, name: user.name }, process.env.JWT_SECRET as Secret, {
            expiresIn: "1h",
        });
        return res.status(200).json({token: token});
    }
}


export default AuthenticateService;