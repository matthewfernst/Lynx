import { GraphQLError } from "graphql";

import { checkHasUserId, checkIsValidUserAndHasValidInvite, checkIsValidParty } from "../../auth";
import { addItemsToArray, deleteItemsFromArray } from "../../aws/dynamodb";
import { Context, LOG_LEVEL } from "../../index";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lynxStack";
import { FORBIDDEN, User } from "../../types";

interface Args {
    partyId: string;
}

const joinParty = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    const party = await checkIsValidParty(context, args.partyId);
    if (!party.invitedUsers.includes(context.userId)) {
        throw new GraphQLError("Not Invited To Requested Party", {
            extensions: { code: FORBIDDEN, partyId: args.partyId }
        });
    }

    console[LOG_LEVEL](`Joining party with id ${args.partyId}`);
    await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "invitedUsers", [context.userId]);
    await deleteItemsFromArray(USERS_TABLE, context.userId, "partyInvites", [args.partyId]);
    await addItemsToArray(PARTIES_TABLE, args.partyId, "users", [context.userId]);
    return await addItemsToArray(USERS_TABLE, context.userId, "parties", [args.partyId]);
};

export default joinParty;
