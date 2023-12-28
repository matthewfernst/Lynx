import { GraphQLError } from "graphql";

import { checkHasUserId, checkIsValidUserAndHasValidInvite, checkIsValidParty } from "../../auth";
import { deleteItemsFromArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lynxStack";
import { FORBIDDEN, User } from "../../types";

interface Args {
    partyId: string;
}

const leaveParty = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    const party = await checkIsValidParty(context, args.partyId);
    if (!party.users.includes(context.userId)) {
        throw new GraphQLError("Not In Requested Party", {
            extensions: { code: FORBIDDEN, partyId: args.partyId }
        });
    }

    console.log(`Leaving party token for with id ${context.userId}`);
    await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "users", [context.userId]);
    return (await deleteItemsFromArray(USERS_TABLE, context.userId, "parties", [
        args.partyId
    ])) as User;
};

export default leaveParty;
