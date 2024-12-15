import { GraphQLResolveInfo } from "graphql";

import {
    USERS_TABLE,
    PROFILE_PICS_BUCKET,
    SLOPES_UNZIPPED_BUCKET,
    LEADERBOARD_TABLE
} from "../../../infrastructure/stacks/lynxApiStack";

import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { deleteAllItems, deleteItem } from "../../aws/dynamodb";
import { deleteObjectsInBucket } from "../../aws/s3";
import { Context } from "../../index";
import { DatabaseUser } from "../../types";

const deleteUser = async (
    _: unknown,
    args: Record<string, never>,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<DatabaseUser> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    console.info(`Deleting user with id ${context.userId}`);
    await deleteObjectsInBucket(PROFILE_PICS_BUCKET, context.userId);
    await deleteObjectsInBucket(SLOPES_UNZIPPED_BUCKET, context.userId);
    await deleteAllItems(LEADERBOARD_TABLE, context.userId);
    return await deleteItem(USERS_TABLE, context.userId);
};

export default deleteUser;
