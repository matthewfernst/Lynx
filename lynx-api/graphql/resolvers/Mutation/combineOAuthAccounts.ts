import { GraphQLError } from "graphql";

import { Context } from "../../index";
import { USERS_TABLE, deleteItem, getItemByIndex, updateItem } from "../../aws/dynamodb";
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
    const otherUser = (await getItemByIndex(USERS_TABLE, idKey, id)) as User;
    if (!otherUser) {
        if (!token) {
            throw new GraphQLError("User Does Not Exist and No Token Provided", {
                extensions: { code: BAD_REQUEST }
            });
        }
        await verifyToken(type, id, token);
        return (await updateItem(USERS_TABLE, context.userId as string, idKey, id)) as User;
    }
    await deleteItem(USERS_TABLE, otherUser.id);
    await deleteObjectsInBucket(profilePictureBucketName, otherUser.id);
    await deleteObjectsInBucket(toRunRecordsBucket, otherUser.id);
    return (await updateItem(USERS_TABLE, context.userId as string, idKey, id)) as User;
};

export default combineOAuthAccounts;
