import { Request, Response, Router } from "express";
import UserService from "../../services/user";
import { validateUserCreation } from "../../middleware/requestValidation";

class RegisterRoute {
    public router: Router;
    private userService: UserService;

    constructor() {
        this.router = Router();
        this.userService = new UserService();
        this.initializeRoutes();
    }

    private initializeRoutes() {
        this.router.post("/", validateUserCreation, this.createUser.bind(this));
    }

    private async createUser(req: Request, res: Response): Promise<void> {
        try {
            await this.userService.save(req, res);
        } catch (error) {
            res.status(500).json({ message: "Internal Server Error", error });
        }
    }
}

export default new RegisterRoute().router;
