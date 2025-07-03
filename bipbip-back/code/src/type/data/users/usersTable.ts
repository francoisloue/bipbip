import { ColumnType, Generated, Insertable, Selectable, Updateable } from 'kysely'

export interface UsersTable {
    id: Generated<number>,
    name: string,
    surname: string,
    created_at: ColumnType<Date, string | undefined, null>
    age: number,
    weight: number,
    height: number
}

export type User = Selectable<UsersTable>
export type NewUser = Insertable<UsersTable>
export type UpdateUser = Updateable<UsersTable>