import { GraphQLError } from "graphql";

import { checkHasUserId, checkIsLoggedInAndHasValidInvite, checkIsValidParty } from "../../auth";
import { addItemsToArray, deleteItemsFromArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { User } from "../../types";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    partyId: string;
}

const joinParty = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    const party = await checkIsValidParty(args.partyId);

    if (!party.invitedUsers.includes(userId)) {
        throw new GraphQLError("You are not invited to this party", {
            extensions: { code: "FORBIDDEN", partyId: args.partyId }
        });
    }
    console.log(`Joining party with id ${args.partyId}`);
    await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "invitedUsers", [userId]);
    await deleteItemsFromArray(USERS_TABLE, userId, "partyInvites", [args.partyId]);
    await addItemsToArray(PARTIES_TABLE, args.partyId, "users", [userId]);
    return (await addItemsToArray(USERS_TABLE, userId, "parties", [args.partyId])) as User;
};

export default joinParty;
