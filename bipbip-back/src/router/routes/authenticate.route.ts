import { Request, Response, Router } from "express";
import { validateUserAuthRequest } from "../../middleware/requestValidation";
import AuthenticateService from "../../services/authenticate";

class RegisterRoute {
    public router: Router;
    private authService: AuthenticateService;

    constructor() {
        this.router = Router();
        this.authService = new AuthenticateService();
        this.initializeRoutes();
    }

    private initializeRoutes() {
        this.router.post("/", validateUserAuthRequest, this.authUser.bind(this));
    }

    private async authUser(req: Request, res: Response): Promise<void> {
        try {
            await this.authService.login(req, res);
        } catch (error) {
            res.status(500).json({ message: "Internal Server Error", error });
        }
    }
}

export default new RegisterRoute().router;
