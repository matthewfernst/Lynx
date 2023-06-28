import { Context } from "../../index";
import { User } from "../../types";
import { DYNAMODB_TABLE_USERS, getItem, getItemFromDynamoDBResult } from "../../aws/dynamodb";

interface Args {
    id: string;
}

const userLookup = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<User | null> => {
    const queryOutput = await getItem(DYNAMODB_TABLE_USERS, args.id);
    return getItemFromDynamoDBResult(queryOutput) as User | null;
};

export default userLookup;
