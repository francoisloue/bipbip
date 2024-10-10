import { ResultSetHeader, RowDataPacket } from "mysql2";
import connection from "../db";
import { User } from "../types/user.type";
import bcrypt from "bcrypt";
import { Event } from "../types/event.type";

interface EventControllerInterface {
    save(event: Event): Promise<Event>;
    getAllByAuthor(userId: string | number | undefined): Promise<Event>;
    retrieveById(eventId: string | number | undefined): Promise<Event>
}

class EventController implements EventControllerInterface {
    getAllByAuthor(userId: string | number | undefined): Promise<Event> {
        return new Promise((resolve, reject) => {
            connection.query<Event[] & RowDataPacket[][]>(
                "SELECT * FROM events WHERE author = ?",
                [userId],
                (err, res) => {
                    if (err) reject(err);
                    else {
                        const event = res?.[0] as Event;
                        if (event) resolve(event)
                        else reject(`No event found with author = ${userId}`)
                    }
                }
              );
        })
    }
    save(event: Event): Promise<Event> {
        return new Promise((resolve, reject) => {
            connection.query<ResultSetHeader>(
                "INSERT INTO events (name, description, author, creation_date, take_pill_date, medication) VALUES(?,?,?,?,?,?)",
                [
                    event.name,
                    event.description,
                    event.author,
                    event.creationDate,
                    event.takePillDate,
                    event.medication
                ],
                (err, res) => {
                    if (err) reject(err);
                    else
                        this.retrieveById(res.insertId)
                    .then((event) => resolve(event))
                    .catch(reject);
                }
            );
        });
    };

    retrieveById(userId: string | number | undefined): Promise<Event> {
        return new Promise((resolve, reject) => {
            connection.query<Event[] & RowDataPacket[][]>(
                "SELECT * FROM events WHERE id = ?",
                [userId],
                (err, res) => {
                    if (err) reject(err);
                    else {
                        const event = res?.[0] as Event;
                        if (event) resolve(event)
                        else reject(`No event found with id = ${userId}`)
                    }
                }
              );
        })
    };
}
    
export default new EventController();