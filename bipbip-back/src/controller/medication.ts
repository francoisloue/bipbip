import { ResultSetHeader, RowDataPacket } from "mysql2";
import connection from "../db";
import { Event } from "../types/event.type";
import { Medication } from "../types/medication.type";

interface MedicationControllerInterface {
    save(medication: Medication): Promise<Medication>;
    retrieveById(medicationId: string | number | undefined): Promise<Medication>;
    retrieveAll(): Promise<Medication[]>;
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
                    .then((medication) => resolve(medication))
                    .catch(reject);
                }
            );
        });
    };

    retrieveById(medicationId: string | number | undefined): Promise<Medication> {
        return new Promise((resolve, reject) => {
            connection.query<Medication[] & RowDataPacket[][]>(
                "SELECT * FROM medications WHERE id = ?",
                [medicationId],
                (err, res) => {
                    if (err) reject(err);
                    else {
                        const user = res?.[0] as Medication;
                        if (user) resolve(user)
                        else reject(`No user found with id = ${medicationId}`)
                    }
                }
              );
        })
    };

    retrieveAll(): Promise<Medication[]> {
        return new Promise((resolve, reject) => {
            connection.query<Medication[] & RowDataPacket[][]>(
                "SELECT * FROM medications",
                (err, res) => {
                    if (err) reject(err);
                    else resolve(res);
                }
            )
        })
    };

}
    
export default new MedicationController();