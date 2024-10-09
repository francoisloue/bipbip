import { Request, Response } from "express";
import dotenv from "dotenv";

class ApiService {
    constructor() {
        dotenv.config();
    }

    async main(req: Request, res: Response) {
        return {
            version: `http://localhost:${process.env.PORT}/${process.env.ENV}/api/version`,
            healthcheck: `http://localhost:${process.env.PORT}/${process.env.ENV}/api/healthcheck`,
            user: `http://localhost:${process.env.PORT}/${process.env.ENV}/api/user`,
        };
    }
}

export default ApiService;
