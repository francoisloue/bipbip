import { createUser, deleteUser, getUserById, getUsers, updateUser } from "../data/userRepository";
import { NewUser, UpdateUser } from "../type/data/users/usersTable";

class UserActions {
    async getUserListAction() {
        return await getUsers();
    }

    async createUserAction(data: NewUser) {
        return await createUser(data);
    }

    async getUserByIdAction(id: number) {
        return await getUserById(id);
    }
    
    async updateUserAction(id: number, updatedUser: UpdateUser) {
        return await updateUser(id, updatedUser);
    }

    async deleteUserAction(id: number) {
        return await deleteUser(id);
    }
}

export default new UserActions();