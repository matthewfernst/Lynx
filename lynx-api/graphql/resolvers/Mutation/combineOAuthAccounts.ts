import { GraphQLError } from "graphql";

import { deleteItem, getItemByIndex, updateItem } from "../../aws/dynamodb";
import { BAD_REQUEST, checkHasUserId, checkIsLoggedInAndHasValidInvite } from "../../auth";
import { deleteObjectsInBucket, profilePictureBucketName, toRunRecordsBucket } from "../../aws/s3";
import { OAuthType, idKeyFromIdType, verifyToken } from "./createUserOrSignIn";
import { Context } from "../../index";
import { User } from "../../types";
import { USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

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
    const userId = checkHasUserId(context.userId);
    checkIsLoggedInAndHasValidInvite(userId);
    const { type, id, token } = args.combineWith;
    const idKey = idKeyFromIdType(type);
    const otherUser = (await getItemByIndex(USERS_TABLE, idKey, id)) as User;
    if (!otherUser) {
        if (!token) {
            throw new GraphQLError("User Does Not Exist and No Token Provided", {
                extensions: { code: BAD_REQUEST }
            });
        }
        await verifyToken(type, id, token);
        return (await updateItem(USERS_TABLE, userId, idKey, id)) as User;
    }
    await deleteItem(USERS_TABLE, otherUser.id);
    await deleteObjectsInBucket(profilePictureBucketName, otherUser.id);
    await deleteObjectsInBucket(toRunRecordsBucket, otherUser.id);
    return (await updateItem(USERS_TABLE, userId, idKey, id)) as User;
};

export default combineOAuthAccounts;
