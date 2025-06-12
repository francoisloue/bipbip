import { ColumnType, Generated, Insertable, Selectable, Updateable } from "kysely";

export interface EventsTable {
    id: Generated<number>,
    user_id: number,
    name: string
    description: string,
    frequency: 'daily' | 'weekly',
    created_at: ColumnType<Date, string | undefined, null>,
    is_active: boolean,
    medication_id: number,
    take_pill_date: ColumnType<Date, string | undefined, null>,
}

export type Event = Selectable<EventsTable>
export type NewEvent = Insertable<EventsTable>
export type UpdateEvent = Updateable<EventsTable>