import {
    checkHasUserId,
    checkIsValidUserAndHasValidInvite,
    checkIsValidPartyAndIsPartyOwner
} from "../../auth";
import { addItemsToArray } from "../../aws/dynamodb";
import { Context, LOG_LEVEL } from "../../index";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lynxStack";
import { Party } from "../../types";

interface Args {
    partyId: string;
    userId: string;
}

const createPartyInvite = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<Party> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    await checkIsValidPartyAndIsPartyOwner(context, args.partyId);

    console[LOG_LEVEL](`Creating party invite for user with id ${args.userId}`);
    await addItemsToArray(USERS_TABLE, args.userId, "partyInvites", [args.partyId]);
    return await addItemsToArray(PARTIES_TABLE, args.partyId, "invitedUsers", [args.userId]);
};

export default createPartyInvite;
