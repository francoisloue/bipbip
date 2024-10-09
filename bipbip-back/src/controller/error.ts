import { ResultSetHeader, RowDataPacket } from "mysql2";
import connection from "../db";
import { User } from "../types/user.type";
import { SearchParam } from "../db/types/user.model";
import bcrypt from "bcrypt";

interface ErrorControllerInterface {
    generateError(code: number, message: String): object
}

class ErrorController implements ErrorControllerInterface {
    generateError(code: number, message: String): object {
        return {
            status: code,
            errorMessage: message
        }
    }
}
    
export default new ErrorController();