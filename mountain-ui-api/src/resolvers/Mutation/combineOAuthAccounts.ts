import { UserInputError } from "apollo-server-lambda";

import { Context } from "../../index";
import {
    DYNAMODB_TABLE_USERS,
    deleteItem,
    getItem,
    getItemFromDynamoDBResult,
    getItemsByIndex,
    updateItem
} from "../../aws/dynamodb";
import { LoginType, idKeyFromIdType, verifyToken } from "./createUserOrSignIn";
import { User } from "../../types";
import { checkIsLoggedInAndHasValidInvite } from "../../auth";

interface Args {
    combineWith: {
        type: LoginType;
        id: string;
        token?: string;
    };
}

const combineOAuthAccounts = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<User> => {
    checkIsLoggedInAndHasValidInvite(context);
    if (args.combineWith.token) {
        return await updateWithNewLogin(
            context.userId as string,
            args.combineWith.type,
            args.combineWith.id,
            args.combineWith.token
        );
    } else {
        return await mergeExistingAccount(
            context.userId as string,
            args.combineWith.type,
            args.combineWith.id
        );
    }
};

const updateWithNewLogin = async (userId: string, type: LoginType, id: string, token: string) => {
    const idKey = idKeyFromIdType(type);
    await verifyToken(type, id, token);
    await updateItem(DYNAMODB_TABLE_USERS, userId, idKey, id);
    const queryOutput = await getItem(DYNAMODB_TABLE_USERS, userId);
    return getItemFromDynamoDBResult(queryOutput) as User;
};

const mergeExistingAccount = async (userId: string, type: LoginType, id: string) => {
    const idKey = idKeyFromIdType(type);
    const userQuery = await getItemsByIndex(DYNAMODB_TABLE_USERS, idKey, id);
    const otherUser = getItemFromDynamoDBResult(userQuery) as User | null;
    if (!otherUser) {
        throw new UserInputError("No Token Provided And User Does Not Exist");
    }
    await updateItem(DYNAMODB_TABLE_USERS, userId, idKey, id);
    await deleteItem(DYNAMODB_TABLE_USERS, otherUser.id);
    const queryOutput = await getItem(DYNAMODB_TABLE_USERS, userId);
    return getItemFromDynamoDBResult(queryOutput) as User;
};

export default combineOAuthAccounts;
