import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import { User } from "../../types";
import { DYNAMODB_TABLE_NAME_USERS, getItem, getItemFromDynamoDBResult } from "../../aws/dynamodb";

interface Args {
    id: string;
}

const userLookup = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<User | null> => {
    await checkIsLoggedIn(context);
    const queryOutput = await getItem(DYNAMODB_TABLE_NAME_USERS, args.id);
    return getItemFromDynamoDBResult(queryOutput);
};

export default userLookup;