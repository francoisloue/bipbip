import { Request, Response, Router } from "express";

class HealthCheckRoute {
    public router: Router;

    constructor() {
        this.router = Router();
        this.initializeRoutes();
    }

    private initializeRoutes() {
        this.router.get("/", this.getHealthStatus.bind(this));
    }

    private async getHealthStatus(req: Request, res: Response): Promise<void> {
        try {
            const result = {status: "Alive"};
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ message: "Internal Server Error", error });
        }
    }    
}

export default new HealthCheckRoute().router;
