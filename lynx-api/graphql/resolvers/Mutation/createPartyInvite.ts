import {
    checkHasUserId,
    checkIsLoggedInAndHasValidInvite,
    checkIsPartyOwner,
    checkIsValidUser
} from "../../auth";
import { addItemsToArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";
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
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    await checkIsPartyOwner(userId, args.partyId);
    await checkIsValidUser(args.userId);

    console.log(`Creating party invite for user with id ${args.userId}`);
    await addItemsToArray(USERS_TABLE, args.userId, "partyInvites", [args.partyId]);
    return (await addItemsToArray(PARTIES_TABLE, args.partyId, "invitedUsers", [
        args.userId
    ])) as Party;
};

export default createPartyInvite;
