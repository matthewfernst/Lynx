import { GraphQLResolveInfo } from "graphql";

import {
    checkHasUserId,
    checkIsValidUserAndHasValidInvite,
    checkIsValidPartyAndIsPartyOwner
} from "../../auth";
import { addItemsToArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";
import { Party, LOG_LEVEL } from "../../types";

interface Args {
    partyId: string;
    userId: string;
}

const createPartyInvite = async (
    _: unknown,
    args: Args,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<Party> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    await checkIsValidPartyAndIsPartyOwner(context, args.partyId);

    console[LOG_LEVEL](`Creating party invite for user with id ${args.userId}`);
    await addItemsToArray(USERS_TABLE, args.userId, "partyInvites", [args.partyId]);
    return await addItemsToArray(PARTIES_TABLE, args.partyId, "invitedUsers", [args.userId]);
};

export default createPartyInvite;
