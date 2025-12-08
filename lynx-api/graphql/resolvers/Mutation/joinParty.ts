import { GraphQLError, GraphQLResolveInfo } from "graphql";

import {
  checkHasUserId,
  checkIsValidUser,
  checkIsValidParty,
} from "../../auth";
import { addItemsToArray, deleteItemsFromArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import {
  PARTIES_TABLE,
  USERS_TABLE,
} from "../../../infrastructure/stacks/lynxApiStack";
import { FORBIDDEN, DatabaseUser } from "../../types";

interface Args {
  partyId: string;
}

const joinParty = async (
  _: unknown,
  args: Args,
  context: Context,
  _info: GraphQLResolveInfo,
): Promise<DatabaseUser> => {
  checkHasUserId(context);
  await checkIsValidUser(context);
  const party = await checkIsValidParty(context, args.partyId);
  if (!(party.invitedUsers ?? []).includes(context.userId)) {
    throw new GraphQLError("Not Invited To Requested Party", {
      extensions: { code: FORBIDDEN, partyId: args.partyId },
    });
  }

  console.info(`Joining party with id ${args.partyId}`);
  await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "invitedUsers", [
    context.userId,
  ]);
  await deleteItemsFromArray(USERS_TABLE, context.userId, "partyInvites", [
    args.partyId,
  ]);
  await addItemsToArray(PARTIES_TABLE, args.partyId, "users", [context.userId]);
  return await addItemsToArray(USERS_TABLE, context.userId, "parties", [
    args.partyId,
  ]);
};

export default joinParty;
