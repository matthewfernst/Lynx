import { USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";
import { getItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party, User } from "../../types";

const users = async (parent: Party, args: any, context: Context, info: any): Promise<User[]> => {
    return Promise.all(
        parent.users.map(async (userId) => await context.dataloaders.users.load(userId) as User)
    );
};

export default users;
