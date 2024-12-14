import { GraphQLError, GraphQLResolveInfo } from "graphql";

import { checkHasUserId, checkIsValidUserAndHasValidInvite, checkIsValidParty } from "../../auth";
import { deleteItemsFromArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";
import { LOG_LEVEL, FORBIDDEN, User } from "../../types";

interface Args {
    partyId: string;
}

const leaveParty = async (
    _: unknown,
    args: Args,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<User> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    const party = await checkIsValidParty(context, args.partyId);
    if (!party.users.includes(context.userId)) {
        throw new GraphQLError("Not In Requested Party", {
            extensions: { code: FORBIDDEN, partyId: args.partyId }
        });
    }

    console[LOG_LEVEL](`Leaving party token for with id ${context.userId}`);
    await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "users", [context.userId]);
    return deleteItemsFromArray(USERS_TABLE, context.userId, "parties", [args.partyId]);
};

export default leaveParty;
