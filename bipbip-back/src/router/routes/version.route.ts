import { Request, Response, Router } from "express";
import dotenv from "dotenv";

class VersionRoute {
    public router: Router;

    constructor() {
        this.router = Router();
        dotenv.config();
        this.initializeRoutes();
    }

    private initializeRoutes() {
        this.router.get("/", this.getCurrentVersion.bind(this));
    }

    private async getCurrentVersion(req: Request, res: Response): Promise<void> {
        try {
            const result = {version: process.env.VERSION};
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ message: "Internal Server Error", error });
        }
    }    
}

export default new VersionRoute().router;
