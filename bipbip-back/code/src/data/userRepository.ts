import { NewUser, User, UpdateUser } from "../type/data/users/usersTable";
import { db } from "./database";

export async function getUsers(): Promise<User[]>  {
    return await db.selectFrom('users')
        .selectAll()
        .execute()
};

export async function getUserById(id: number): Promise<User | undefined> {
    return await db.selectFrom('users')
        .where('id', '=', id)
        .selectAll()
        .executeTakeFirst()
};

export async function createUser(user: NewUser): Promise<User> {
    return await db.insertInto('users')
        .values(user)
        .returningAll()
        .executeTakeFirstOrThrow()
}

export async function updateUser(id: number, updateWith: UpdateUser): Promise<User | undefined> {
    await db.updateTable('users')
        .set(updateWith)
        .where('id', '=', id)
        .executeTakeFirst()
    
    return getUserById(id);
};

export async function deleteUser(id: number): Promise<User | undefined> {
  return await db.deleteFrom('users').where('id', '=', id)
    .returningAll()
    .executeTakeFirst()
};