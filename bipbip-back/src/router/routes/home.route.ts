import { Request, Response, Router } from "express";
import ApiService from "../../services/home";

class ApiRoutes {
    public router: Router;
    private apiService: ApiService;

    constructor() {
        this.router = Router();
        this.apiService = new ApiService();
        this.initializeRoutes();
    }

    private initializeRoutes() {
        this.router.get("/", this.getHome.bind(this));
    }

    private async getHome(req: Request, res: Response): Promise<void> {
        try {
            const result = await this.apiService.main(req, res);
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ message: "Internal Server Error", error });
        }
    }    
}

export default new ApiRoutes().router;
