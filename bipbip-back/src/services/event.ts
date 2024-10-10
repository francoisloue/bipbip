import jwt, { Secret } from "jsonwebtoken";
import bcrypt from "bcrypt";
import { Request, Response } from "express";
import { User } from "../types/user.type";
import dotenv from "dotenv";
import EventController from "../controller/event";
import { Event } from "../types/event.type";

class EventService {
    constructor() {
        dotenv.config();
    }

    async addEvent(req: Request, res: Response) {
        try {
            const event: Event = req.body;
            const savedEvent: Event = await EventController.save(event);
            return res.status(201).json(savedEvent);
        } catch (err) {
            console.error({ message: 'Error saving Event', error: err });
            return res.status(500).json({ message: 'Error saving Event', error: err });
        }
    }

    async getAllEventByUserId(req: Request, res: Response) {
        try {
            let id: string | number | undefined = req.params.id;
            const allEvent: Event = await EventController.getAllByAuthor(id);
            return res.status(200).json(allEvent)
        } catch (err) {
            console.log('Error retrieving all the events:', err);
            return res.status(500).json({message: 'Error retrieving all the events'})
        }
    }
}


export default EventService;