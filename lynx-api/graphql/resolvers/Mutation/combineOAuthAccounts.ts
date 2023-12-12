import { GraphQLError } from "graphql";

import { Context } from "../../index";
import {
    USERS_TABLE,
    deleteItem,
    getItem,
    getItemFromDynamoDBResult,
    getItemsByIndex,
    updateItem
} from "../../aws/dynamodb";
import { OAuthType, idKeyFromIdType, verifyToken } from "./createUserOrSignIn";
import { User } from "../../types";
import { BAD_REQUEST, checkIsLoggedInAndHasValidInvite } from "../../auth";
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
    const userQuery = await getItemsByIndex(USERS_TABLE, idKey, id);
    const otherUser = getItemFromDynamoDBResult(userQuery) as User | null;
    if (!otherUser) {
        if (!token) {
            throw new GraphQLError("User Does Not Exist and No Token Provided", {
                extensions: { code: BAD_REQUEST }
            });
        }
        await verifyToken(type, id, token);
        return await updateUserAndReturnResult(context.userId as string, idKey, id);
    }
    await deleteItem(USERS_TABLE, otherUser.id);
    await deleteObjectsInBucket(profilePictureBucketName, otherUser.id);
    await deleteObjectsInBucket(toRunRecordsBucket, otherUser.id);
    return await updateUserAndReturnResult(context.userId as string, idKey, id);
};

const updateUserAndReturnResult = async (userId: string, idKey: string, id: string) => {
    await updateItem(USERS_TABLE, userId, idKey, id);
    const queryOutput = await getItem(USERS_TABLE, userId);
    return getItemFromDynamoDBResult(queryOutput) as User;
};

export default combineOAuthAccounts;
