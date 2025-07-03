import { Generated, Insertable, Selectable, Updateable } from 'kysely'

export interface MedicationsTable {
    id: Generated<number>,
    name: string,
    image_url: string,
    notice_url: string
}

export type Medication = Selectable<MedicationsTable>
export type NewMedication = Insertable<MedicationsTable>
export type UpdateMedication = Updateable<MedicationsTable>