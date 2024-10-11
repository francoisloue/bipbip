import { ResultSetHeader, RowDataPacket } from "mysql2";
import connection from "../db";
import { User } from "../types/user.type";
import bcrypt from "bcrypt";

interface RegisterControllerInterface {
    save(user: User): Promise<User>;
}

class RegisterController implements RegisterControllerInterface {
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

    retrieveById(userId: string | number | undefined): Promise<User> {
        return new Promise((resolve, reject) => {
            connection.query<User[] & RowDataPacket[][]>(
                "SELECT * FROM users WHERE id = ?",
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
}
    
export default new RegisterController();