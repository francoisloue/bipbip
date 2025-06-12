import { createEvent, deleteEvent, getEventById, getEvents, updateEvent, getEventsByUserId } from "../data/eventRepository";
import { NewEvent, UpdateEvent } from "../type/data/events/eventsTable";

class EventActions {
    async getEventListAction() {
        return await getEvents();
    }

    async createEventAction(data: NewEvent) {
        return await createEvent(data);
    }

    async getEventByIdAction(id: number) {
        return await getEventById(id);
    }
    
    async updateEventAction(id: number, updatedEvent: UpdateEvent) {
        return await updateEvent(id, updatedEvent);
    }

    async deleteEventAction(id: number) {
        return await deleteEvent(id);
    }

    async getEventByUserId(userId: number) {
        return await getEventsByUserId(userId);
    }
}

export default new EventActions();