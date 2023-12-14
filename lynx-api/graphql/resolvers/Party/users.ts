import { USERS_TABLE, getItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party, User } from "../../types";

const users = async (parent: Party, args: any, context: Context, info: any): Promise<User[]> => {
    return Promise.all(
        parent.users.map(async (user) => (await getItem(USERS_TABLE, user)) as User)
    );
};

export default users;
