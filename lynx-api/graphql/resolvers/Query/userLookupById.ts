import { Context } from "../../index";
import { User } from "../../types";
import { USERS_TABLE, getItem } from "../../aws/dynamodb";

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
