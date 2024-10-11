import { RowDataPacket } from "mysql2";
import connection from "../db";
import { User } from "../types/user.type";

interface AuthenticateControllerInterface {
    retrieveByName(userName: string): Promise<User>;
}

class AuthenticateController implements AuthenticateControllerInterface {
    retrieveByName(userName: string): Promise<User> {
        return new Promise((resolve, reject) => {
            connection.query<User[] & RowDataPacket[][]>(
                "SELECT name, password FROM users WHERE name = ?",
                [userName],
                (err, res) => {
                    if (err) reject(err);
                    else {
                        const user = res?.[0] as User;
                        if (user) resolve(user)
                        else reject(`No user found with name = ${userName}`)
                    }
                }
              );
        })
    };
}
    
export default new AuthenticateController();