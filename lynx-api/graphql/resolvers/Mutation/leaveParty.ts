import { GraphQLError } from "graphql";

import { checkHasUserId, checkIsLoggedInAndHasValidInvite, checkIsValidParty } from "../../auth";
import { Context } from "../../index";
import { User } from "../../types";
import { deleteItemsFromArray } from "../../aws/dynamodb";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    partyId: string;
}

const leaveParty = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    const party = await checkIsValidParty(args.partyId);

    if (!party.users.includes(userId)) {
        throw new GraphQLError("You are not in this party", {
            extensions: { code: "FORBIDDEN", partyId: args.partyId }
        });
    }
    console.log(`Leaving party token for with id ${userId}`);
    await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "users", [userId]);
    return (await deleteItemsFromArray(USERS_TABLE, userId, "parties", [args.partyId])) as User;
};

export default leaveParty;
