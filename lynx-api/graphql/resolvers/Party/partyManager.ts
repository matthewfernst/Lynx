import { USERS_TABLE } from "../../../infrastructure/lib/infrastructure";
import { getItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party, User } from "../../types";

const partyManager = async (
    parent: Party,
    args: any,
    context: Context,
    info: any
): Promise<User> => {
    return await context.dataloaders.users.load(parent.partyManager) as User;
};

export default partyManager;
