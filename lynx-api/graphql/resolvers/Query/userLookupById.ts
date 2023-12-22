import { Context } from "../../index";
import { User } from "../../types";
import { getItem } from "../../aws/dynamodb";
import { USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    id: string;
}

const userLookupById = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<User | undefined> => {
    return await getItem(USERS_TABLE, args.id);
};

export default userLookupById;
