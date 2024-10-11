import { Request, Response } from "express";
import dotenv from "dotenv";
import MedicationController from "../controller/medication";
import { Medication } from "../types/medication.type";

class MedicationService {
    constructor() {
        dotenv.config();
    }

    async addMedication(req: Request, res: Response) {
        try {
            const medication: Medication = req.body;
            const savedMedication: Medication = await MedicationController.save(medication);
            return res.status(201).json(savedMedication);
        } catch (err) {
            console.error({ message: 'Error saving Event', error: err });
            return res.status(500).json({ message: 'Error saving Event', error: err });
        }
    }

    async getMedicationById(req: Request, res: Response) {
        try {
            let id: string | number | undefined = req.params.id;
            const medication: Medication = await MedicationController.retrieveById(id);
            return res.status(200).json(medication)
        } catch (err) {
            console.log('Error retrieving all the events:', err);
            return res.status(500).json({message: 'Error retrieving all the events'})
        }
    }

    async getAllMedication(req: Request, res: Response) {
        try {
            const medication: Medication[] = await MedicationController.retrieveAll();
            return res.status(200).json(medication)
        } catch (err) {
            console.log('Error retrieving all the events:', err);
            return res.status(500).json({message: 'Error retrieving all the events'})
        }
    }
}


export default MedicationService;