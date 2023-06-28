import { Context } from "../../index";
import { User } from "../../types";
import { DYNAMODB_TABLE_USERS, getItem, getItemFromDynamoDBResult } from "../../aws/dynamodb";

const selfLookup = async (_: any, args: {}, context: Context, info: any): Promise<User | null> => {
    if (!context.userId) {
        return null;
    }
    const queryOutput = await getItem(DYNAMODB_TABLE_USERS, context.userId);
    return getItemFromDynamoDBResult(queryOutput) as User | null;
};

export default selfLookup;
