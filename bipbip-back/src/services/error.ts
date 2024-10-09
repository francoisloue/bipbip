import { Request, Response } from "express";
import ErrorController from "../controller/error"

class ErrorService {
    async cantGet(req: Request, res: Response) {
        return res.status(400).json(ErrorController.generateError(400, "Can't use GET method on this endpoint"))
    }

    async cantPost(req: Request, res: Response) {
        return res.status(400).json(ErrorController.generateError(400, "Can't use POST method on this endpoint"))
    }
}

export default ErrorService;
