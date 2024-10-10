import { ResultSetHeader, RowDataPacket } from "mysql2";
import connection from "../db";
import { Event } from "../types/event.type";
import { Medication } from "../types/medication.type";

interface MedicationControllerInterface {
    save(medication: Medication): Promise<Medication>;
    retrieveById(medicationId: string | number | undefined): Promise<Medication>
}

class MedicationController implements MedicationControllerInterface {
    save(medication: Medication): Promise<Medication> {
        return new Promise((resolve, reject) => {
            connection.query<ResultSetHeader>(
                "INSERT INTO medications (name, description, icone) VALUES(?,?,?)",
                [
                    medication.name,
                    medication.description,
                    medication.icone
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

    retrieveById(medicationId: string | number | undefined): Promise<Event> {
        return new Promise((resolve, reject) => {
            connection.query<Event[] & RowDataPacket[][]>(
                "SELECT * FROM medications WHERE id = ?",
                [medicationId],
                (err, res) => {
                    if (err) reject(err);
                    else {
                        const event = res?.[0] as Event;
                        if (event) resolve(event)
                        else reject(`No medication found with id = ${medicationId}`)
                    }
                }
              );
        })
    };
}
    
export default new MedicationController();