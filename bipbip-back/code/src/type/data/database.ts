import { EventsTable } from "./events/eventsTable";
import { MedicationsTable } from "./medications/medicationsTable";
import { UsersTable } from "./users/usersTable";

export interface BipBipDatabase {
    users: UsersTable,
    events: EventsTable,
    medications: MedicationsTable   
}