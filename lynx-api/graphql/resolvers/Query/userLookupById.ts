import { Context } from "../../index";
import { User } from "../../types";
import { USERS_TABLE, getItem, getItemFromDynamoDBResult } from "../../aws/dynamodb";

interface Args {
    id: string;
}

const userLookupById = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<User | null> => {
    const queryOutput = await getItem(USERS_TABLE, args.id);
    return getItemFromDynamoDBResult(queryOutput) as User | null;
};

export default userLookupById;
