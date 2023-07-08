import { Context } from "../../index";
import { checkIsLoggedInAndHasValidInvite } from "../../auth";
import {
    DYNAMODB_TABLE_USERS,
    getItem,
    getItemFromDynamoDBResult,
    updateItem
} from "../../aws/dynamodb";
import { User } from "../../types";

interface Args {
    userData: {
        key: string;
        value: string;
    }[];
}

const editUser = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    await checkIsLoggedInAndHasValidInvite(context);
    for (const data of args.userData) {
        await updateItem(DYNAMODB_TABLE_USERS, context.userId as string, data.key, data.value);
    }
    const queryOutput = await getItem(DYNAMODB_TABLE_USERS, context.userId as string);
    return getItemFromDynamoDBResult(queryOutput) as User;
};

export default editUser;
