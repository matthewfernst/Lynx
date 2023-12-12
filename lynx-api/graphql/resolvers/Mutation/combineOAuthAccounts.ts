import { GraphQLError } from "graphql";

import { Context } from "../../index";
import {
    DYNAMODB_TABLE_USERS,
    deleteItem,
    getItem,
    getItemFromDynamoDBResult,
    getItemsByIndex,
    updateItem
} from "../../aws/dynamodb";
import { OAuthType, idKeyFromIdType, verifyToken } from "./createUserOrSignIn";
import { User } from "../../types";
import { checkIsLoggedInAndHasValidInvite } from "../../auth";
import { deleteObjectsInBucket, profilePictureBucketName, toRunRecordsBucket } from "../../aws/s3";

interface Args {
    combineWith: {
        type: OAuthType;
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
    const { type, id, token } = args.combineWith;
    const idKey = idKeyFromIdType(type);
    const userQuery = await getItemsByIndex(DYNAMODB_TABLE_USERS, idKey, id);
    const otherUser = getItemFromDynamoDBResult(userQuery) as User | null;
    if (!otherUser) {
        if (!token) {
            throw new GraphQLError("User Does Not Exist and No Token Provided");
        }
        await verifyToken(type, id, token);
        return await updateUserAndReturnResult(context.userId as string, idKey, id);
    }
    await deleteItem(DYNAMODB_TABLE_USERS, otherUser.id);
    await deleteObjectsInBucket(profilePictureBucketName, otherUser.id);
    await deleteObjectsInBucket(toRunRecordsBucket, otherUser.id);
    return await updateUserAndReturnResult(context.userId as string, idKey, id);
};

const updateUserAndReturnResult = async (userId: string, idKey: string, id: string) => {
    await updateItem(DYNAMODB_TABLE_USERS, userId, idKey, id);
    const queryOutput = await getItem(DYNAMODB_TABLE_USERS, userId);
    return getItemFromDynamoDBResult(queryOutput) as User;
};

export default combineOAuthAccounts;
