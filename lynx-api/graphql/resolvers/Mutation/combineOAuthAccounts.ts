import { ApolloServerErrorCode } from "@apollo/server/errors";
import { GraphQLError, GraphQLResolveInfo } from "graphql";

import {
  USERS_TABLE,
  PROFILE_PICS_BUCKET,
  SLOPES_UNZIPPED_BUCKET,
  LEADERBOARD_TABLE,
} from "../../../infrastructure/stacks/lynxApiStack";

import {
  deleteAllItems,
  deleteItem,
  getItemByIndex,
  updateItem,
} from "../../aws/dynamodb";
import { deleteObjectsInBucket } from "../../aws/s3";
import { checkHasUserId, checkIsValidUser } from "../../auth";
import { Context } from "../../index";
import { DatabaseUser } from "../../types";
import { OAuthType, idKeyFromIdType, verifyToken } from "./oauthSignIn";

interface Args {
  combineWith: {
    type: keyof typeof OAuthType;
    id: string;
    token?: string;
  };
}

const combineOAuthAccounts = async (
  _: unknown,
  args: Args,
  context: Context,
  _info: GraphQLResolveInfo,
): Promise<DatabaseUser> => {
  checkHasUserId(context);
  await checkIsValidUser(context);
  const { type, id, token } = args.combineWith;
  const idKey = idKeyFromIdType[OAuthType[type]];
  const otherUser = (await getItemByIndex(
    USERS_TABLE,
    idKey,
    id,
  )) as DatabaseUser;
  if (!otherUser) {
    if (!token) {
      throw new GraphQLError("User Does Not Exist and No Token Provided", {
        extensions: { code: ApolloServerErrorCode.BAD_REQUEST },
      });
    }
    await verifyToken(OAuthType[type], id, token);
    return await updateItem(USERS_TABLE, context.userId, idKey, id);
  }
  await deleteItem(USERS_TABLE, otherUser.id);
  await deleteObjectsInBucket(PROFILE_PICS_BUCKET, otherUser.id);
  await deleteObjectsInBucket(SLOPES_UNZIPPED_BUCKET, otherUser.id);
  await deleteAllItems(LEADERBOARD_TABLE, otherUser.id);
  return await updateItem(USERS_TABLE, context.userId, idKey, id);
};

export default combineOAuthAccounts;
