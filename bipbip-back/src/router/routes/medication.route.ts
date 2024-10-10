import { Request, Response, Router } from "express";
import { validateNewMedicationRequest } from "../../middleware/requestValidation";
import MedicationService from "../../services/medication";

class EventRoute {
    public router: Router;
    private medicationService: MedicationService;

    constructor() {
        this.router = Router();
        this.medicationService = new MedicationService();
        this.initializeRoutes();
    }

    private initializeRoutes() {
        this.router.post("/", validateNewMedicationRequest, this.newMedication.bind(this));
        this.router.get("/:id", this.getById.bind(this));
    }

    private async newMedication(req: Request, res: Response): Promise<void> {
        try {
            await this.medicationService.addMedication(req, res);
        } catch (error) {
            res.status(500).json({ message: "Internal Server Error", error });
        }
    }

    private async getById(req: Request, res: Response): Promise<void> {
        try {
            const result = await this.medicationService.getMedicationById(req, res);
            result;
        } catch (error) {
            res.status(500).json({message: "Internal Server Error", error});
        }
    }


}

export default new EventRoute().router;
