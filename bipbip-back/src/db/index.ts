import { Credentials } from "./db.config";
import mysql from "mysql2";

export default mysql.createConnection({
    host: Credentials.HOST,
    user: Credentials.USER,
    password: Credentials.PASSWORD,
    database: Credentials.DB
});