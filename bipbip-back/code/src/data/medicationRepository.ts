import { UpdateResult } from "kysely";
import { NewMedication, Medication, UpdateMedication } from "../type/data/medications/medicationsTable";
import { db } from "./database";

export async function getMedications(): Promise<Medication[]>  {
    return await db.selectFrom('medications')
        .selectAll()
        .execute()
};

export async function getMedicationById(id: number): Promise<Medication | undefined> {
    return await db.selectFrom('medications')
        .where('id', '=', id)
        .selectAll()
        .executeTakeFirst()
};

export async function createMedication(medication: NewMedication): Promise<Medication> {
    return await db.insertInto('medications')
        .values(medication)
        .returningAll()
        .executeTakeFirstOrThrow()
}

export async function updateMedication(id: number, updateWith: UpdateMedication): Promise<UpdateResult> {
    return await db.updateTable('medications')
        .set(updateWith)
        .where('id', '=', id)
        .executeTakeFirst()
};

export async function deleteMedication(id: number): Promise<Medication | undefined> {
  return await db.deleteFrom('medications').where('id', '=', id)
    .returningAll()
    .executeTakeFirst()
};