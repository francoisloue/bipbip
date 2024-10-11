import { Request, Response, Router } from "express";
import { validateNewEventRequest } from "../../middleware/requestValidation";
import EventService from "../../services/event";

class EventRoute {
    public router: Router;
    private eventService: EventService;

    constructor() {
        this.router = Router();
        this.eventService = new EventService();
        this.initializeRoutes();
    }

    private initializeRoutes() {
        this.router.post("/", validateNewEventRequest, this.newEvent.bind(this));
        this.router.get("/", this.getAllByUserId.bind(this));
    }

    private async newEvent(req: Request, res: Response): Promise<void> {
        try {
            await this.eventService.addEvent(req, res);
        } catch (error) {
            res.status(500).json({ message: "Internal Server Error", error });
        }
    }

    private async getAllByUserId(req: Request, res: Response): Promise<void> {
        try {
            const result = await this.eventService.getAllEventByUserId(req, res);
            result;
        } catch (error) {
            res.status(500).json({message: "Internal Server Error", error});
        }
    }


}

export default new EventRoute().router;
