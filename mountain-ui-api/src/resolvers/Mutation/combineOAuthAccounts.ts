import { UserInputError } from "apollo-server-lambda";

import { Context } from "../../index";
import {
    DYNAMODB_TABLE_NAME_USERS,
    deleteItem,
    getItem,
    getItemFromDynamoDBResult,
    getItemsByIndex,
    updateItem
} from "../../aws/dynamodb";
import { LoginType, idKeyFromIdType } from "./createUserOrSignIn";
import { User } from "../../types";
import { checkIsLoggedInAndHasValidToken } from "../../auth";

interface Args {
    combineWith: {
        type: LoginType;
        id: string;
    }[];
}

const combineOAuthAccounts = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<User> => {
    checkIsLoggedInAndHasValidToken(context);
    for (const data of args.combineWith) {
        const idKey = idKeyFromIdType(data.type);
        const userQuery = await getItemsByIndex(DYNAMODB_TABLE_NAME_USERS, idKey, data.id);
        const otherUser = getItemFromDynamoDBResult(userQuery) as User | null;
        if (!otherUser) {
            throw new UserInputError("OAuth Id Provided That Does Not Exist");
        }
        await updateItem(DYNAMODB_TABLE_NAME_USERS, context.userId as string, idKey, data.id);
        await deleteItem(DYNAMODB_TABLE_NAME_USERS, otherUser.id);
    }
    const queryOutput = await getItem(DYNAMODB_TABLE_NAME_USERS, context.userId as string);
    return getItemFromDynamoDBResult(queryOutput) as User;
};

export default combineOAuthAccounts;
