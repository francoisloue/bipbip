import { Request, Response, Router } from "express";
import UserService from "../../services/user";
import ErrorService from "../../services/error";

class UserRoutes {
    public router: Router;
    private userService: UserService;
    private errorService: ErrorService;

    constructor() {
        this.router = Router();
        this.userService = new UserService();
        this.errorService = new ErrorService();
        this.initializeRoutes();
    }

    private initializeRoutes() {
        this.router.get("/", this.getAllUser.bind(this));
        this.router.get("/:id", this.getUserById.bind(this));
        this.router.post("/", this.cantPost.bind(this));
    }

    private async getAllUser(req: Request, res: Response): Promise<void> {
        try {
            const result = await this.userService.retrieveAll(req, res);
            result;
        } catch (error) {
            res.status(500).json({ message: "Internal Server Error", error });
        }
    }

    private async getUserById(req: Request, res: Response): Promise<void> {
        try {
            const result = await this.userService.retrieveById(req, res);
            result;
        } catch (error) {
            res.status(500).json({message: "Internal Server Error", error});
        }
    }

    private async cantPost(req: Request, res: Response): Promise<void> {
        try {
            const result = await this.errorService.cantPost(req, res);
            result;
        } catch (error) {
            res.status(500).json({message: "Internal Server Error", error});
        }
    }
}

export default new UserRoutes().router;
