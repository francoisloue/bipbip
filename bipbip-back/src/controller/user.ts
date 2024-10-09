import { ResultSetHeader, RowDataPacket } from "mysql2";
import connection from "../db";
import { User } from "../types/user.type";
import { SearchParam } from "../db/types/user.model";
import bcrypt from "bcrypt";

interface UserControllerInterface {
    save(user: User): Promise<User>;
    retrieveAll(searchParams?: SearchParam): Promise<User[]>;
    retrieveById(tutorialId: string | number | undefined): Promise<User>;
    delete(tutorialId: string | number | undefined): Promise<number>;
    deleteAll(): Promise<number>;
}

class UserController implements UserControllerInterface {
    save(user: User): Promise<User> {
        return new Promise((resolve, reject) => {
            connection.query<ResultSetHeader>(
                "INSERT INTO users (name, password) VALUES(?,?)",
                [
                    user.name,
                    bcrypt.hashSync(user.password as string, 10)
                ],
                (err, res) => {
                    if (err) reject(err);
                    else
                        this.retrieveById(res.insertId)
                    .then((user) => resolve(user))
                    .catch(reject);
                }
            );
        });
    };

    retrieveAll(searchParams?: SearchParam): Promise<User[]> {
        let query: string = "SELECT id, name FROM users";
        let condition: string = "";
        if (searchParams?.id) condition += ` id=${searchParams.id}`
        if (searchParams?.name) condition += ` name=${searchParams.name}`

        if (condition.length) query += ` WHERE ${condition}`
        return new Promise((resolve, reject) => {
            connection.query<User[] & RowDataPacket[][]>(
                query, (err, res) => {
                    if (err) reject(err);
                    else resolve(res);
                }
            )
        })
    };

    retrieveById(userId: string | number | undefined): Promise<User> {
        return new Promise((resolve, reject) => {
            connection.query<User[] & RowDataPacket[][]>(
                "SELECT id, name FROM users WHERE id = ?",
                [userId],
                (err, res) => {
                    if (err) reject(err);
                    else {
                        const user = res?.[0] as User;
                        if (user) resolve(user)
                        else reject(`No user found with id = ${userId}`)
                    }
                }
              );
        })
    };

    delete(userId: string | number | undefined): Promise<number> {
        return new Promise((resolve, reject) => {
            connection.query<ResultSetHeader>(
                "DELETE FROM users WHERE id = ?",
                [userId],
                (err, res) => {
                    if (err) reject(err)
                    else resolve(res.affectedRows)
                }
            )
        })
    };

    deleteAll(): Promise<number> {
        return new Promise((resolve, reject) => {
            connection.query<ResultSetHeader>("DELETE FROM users", (err, res) => {
              if (err) reject(err);
              else resolve(res.affectedRows);
            });
          });
    };
}
    
export default new UserController();