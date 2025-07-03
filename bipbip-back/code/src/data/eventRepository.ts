import { UpdateResult } from "kysely";
import { NewEvent, Event, UpdateEvent } from "../type/data/events/eventsTable";
import { db } from "./database";

export async function getEvents(): Promise<Event[]>  {
    return await db.selectFrom('events')
        .selectAll()
        .execute()
};

export async function getEventById(id: number): Promise<Event | undefined> {
    return await db.selectFrom('events')
        .where('id', '=', id)
        .selectAll()
        .executeTakeFirst()
};

export async function createEvent(event: NewEvent): Promise<Event> {
    return await db.insertInto('events')
        .values(event)
        .returningAll()
        .executeTakeFirstOrThrow()
}

export async function updateEvent(id: number, updateWith: UpdateEvent): Promise<UpdateResult> {
    return await db.updateTable('events')
        .set(updateWith)
        .where('id', '=', id)
        .executeTakeFirst()
};

export async function deleteEvent(id: number): Promise<Event | undefined> {
  return await db.deleteFrom('events').where('id', '=', id)
    .returningAll()
    .executeTakeFirst()
};

export async function getEventsByUserId(userId: number):  Promise<Event[]> {
    return await db.selectFrom('events')
        .selectAll()
        .where('user_id', '=', userId)
        .execute()
}